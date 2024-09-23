import type { Store } from 'redux'

// import { configureStore } from '../../npm/@reduxjs/toolkit/src'
// import { createStore } from '../../npm/redux/src'
// import { createStore } from '../../npm/redux/dist/redux.mjs'
import { hilog } from '@kit.PerformanceAnalysisKit';

// const store: Store = createStore({
//   reducer: (state, action) => state,
// })
//
// class IndexAction extends Action {
//
// }
//
// class IndexState {
//
// }
//
// function reducer(state: IndexState, action: IndexAction): IndexState {
//   return new IndexState()
// }

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('HelloWorld')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(_ => {
          hilog.info(0x0000, "testTag", "store created: %{public}s", createStore)
        })
    }
    .height('100%')
    .width('100%')
  }
}