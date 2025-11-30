# PriceTracker

## Services
- Simple interface with update publishers.
- Synchronized using a global actor (alternatively the service itself to become an actor, but this way the synchronization can be enforced at the interface level).
- Allows subscribing and unsibscribing for prices with symbol identifiers.
- Connection state shows the current state.
- Multiple price updates are supported with the same message/payload but the Echo service still pushes updates one by one on purpose to identify potential performance issues.

## UI

### FeedView 
- Plain UI with injected viewModel.
- The view model handles updates and reordering by placing the element at its proper position.
- Price updates could be throttled if there are performance issues. This can be easily implemented by removing the @Published modifier from FeedView's data property and calling objectWillChange.send() whenever an update is to be propagated.

### Details view
- Plain UI with injected service; the ViewModel is created locally - another option is to pass a filtered publisher, not the entire service.

## Synchronization/Concurrency
- The PriceService is isolated using a global actor.
- The view models are isolated using MainActor as they trigger UI chages.
- The project uses Swift6 so proper use of concurrency is strictly enforced.

## What's not implemented
- Error handling and reconnect logic in EchoPriceService.
- There was no description of the service so I added previousPrice to the prices message. Alternatively the service has to keep the previous price to build the PriceData objects.
- Integration/UI tests.