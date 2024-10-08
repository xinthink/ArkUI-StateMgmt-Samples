import type { Store, Action, Unsubscribe } from 'redux'

import { legacy_createStore } from 'redux'
import { hilog } from '@kit.PerformanceAnalysisKit';

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
    }
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.SpaceEvenly)
  }
}