import type { Store, Action, Unsubscribe } from 'redux'

import { legacy_createStore } from 'redux'
import { hilog } from '@kit.PerformanceAnalysisKit';
import { taskpool, JSON } from '@kit.ArkTS';
import { emitter } from '@kit.BasicServicesKit';
import { Counter } from './counter';

class CounterAction implements Action<string> {
  type: string = ""
}

class CounterState {
  value: number = 0
}

const store: Store<CounterState, CounterAction> = legacy_createStore((state = { value: 0 }, action) => {
  switch (action.type) {
    case "incr":
      return { value: state.value + 1 } as CounterState
    case "decr":
      return { value: state.value - 1 } as CounterState
    default:
      return state
  }
})

@Entry
@Component
struct Index {
  title: string = 'Counter';
  @State count: number = 0;
  unsubscribe: Unsubscribe | null = null;

  aboutToAppear(): void {
    this.unsubscribe = store.subscribe(() => {
      hilog.debug(0x0000, "testTag", "store updated")
      this.count = store.getState().value;

      // Immutability tests
      // const tmpVal = store.getState().value;
      // store.getState().value += 10;
      // const currVal = store.getState().value;
      // if (currVal != tmpVal) {
      //   hilog.error(0x0000, "testTag", `state is mutated to be ${currVal}, but it should be ${tmpVal}`)
      // }
    })
  }

  aboutToDisappear(): void {
    this.unsubscribe && this.unsubscribe()
  }

  build() {
    Column() {
      Text(this.title)
        .fontSize(50)
        .fontWeight(FontWeight.Bold)

      Text(`${this.count}`)
        .fontSize(40)
        .fontWeight(FontWeight.Bold)

      Row() {
        Button('+')
          .fontWeight(FontWeight.Bold)
          .fontSize(30)
          .onClick(_ => {
            store.dispatch({type: "incr"} as CounterAction)
          })
        Button('-')
          .fontWeight(FontWeight.Bold)
          .fontSize(30)
          .onClick(_ => {
            store.dispatch({type: "decr"} as CounterAction)
          })
      }

      Button('Send')
        .fontWeight(FontWeight.Bold)
        .fontSize(40)
        .onClick(_ => {
          sendMessages()
        })
    }
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.SpaceEvenly)
  }
}

async function sendMessages() {
  const json = '{"name": "counter", "value": 0}'
  const cnt = JSON.parse(json) as Counter
  hilog.info(0x0000, "testTag", `counter: ${cnt.name} ${cnt.value}`)

  let g = new taskpool.TaskGroup()
  g.addTask(increase, JSON.parse('{"name": "counter1", "value": 1}') as Object)
  g.addTask(increase, JSON.parse('{"name": "counter2", "value": 2}') as Object)
  g.addTask(increase, JSON.parse('{"name": "counter3", "value": 3}') as Object)

  let result: Object[] = await taskpool.execute(g, taskpool.Priority.HIGH)
  result.forEach(c => {
    hilog.info(0x0000, "testTag", `counter: ${(c as Counter).name} ${(c as Counter).value}`)
  })
}

@Concurrent
export async function increase(counter: Object): Promise<Counter> {
  const c = counter as Counter
  c.value += 1
  return c
}

// function* generator() {
//   yield 1;
//   yield 2;
//   yield 3;
// }
