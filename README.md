# Flickr Photo Gallery - Roku Channel For Corus

A Roku channel that displays beautiful photos from Flickr across 14 different categories including Nature, Architecture, Animals, and more. Built with BrightScript and SceneGraph.

## Architecture Overview

The app follows a clean separation of concerns with three main layers:

### 1. **Presentation Layer** (`components/screens/`)
- **MainScreen**: Displays photo rows
- **DetailsScreen**: Full-screen photo view with scrollable descriptions
- **SplashScreen**: Loading screen shown on app startup

### 2. **Business Logic Layer** (`components/services/`)
- **DataManager**: Orchestrates API requests and manages application state
- Handles batch loading (3 rows at a time) to optimize performance
- Manages the lazy-loading pipeline as users scroll

### 3. **Data Layer** (`components/tasks/`)
- **FlickrImageTask**: Background task that fetches photos from the Flickr API
- Runs in a separate thread to keep the UI responsive
- Handles errors gracefully and continues loading remaining categories

## Key Features

### Lazy Loading with Pagination
Instead of fetching all 14 (made it 14 instead of 10 as requested) photo categories upfront, we load them in batches of 3. This significantly improves initial load time and reduces unnecessary API calls. When users scroll within 2 rows of the bottom, the next batch is automatically fetched.

**Why batches of 3?** It strikes a good balance - users see content quickly (under 2 seconds most of the time), but we're not overwhelming the API or wasting bandwidth on photos they might never scroll to.

### Loading Indicators
- **Main Screen**: Shows "Loading more photos..." when fetching additional batches
- **Details Screen**: Displays "Loading image..." while high-res images load
- Initially wanted to use BusySpinner components but opted for simple text labels since they don't require image assets

### Focus Management
The RowList automatically regains focus when navigating back from the details screen. The ScrollableText in the details view gets focus after a 100ms delay to ensure proper rendering.

### Error Handling
If a photo category fails to load (network issue, API error, etc.), the app silently continues loading the next one. I don't want one bad category to break the entire experience.

## Technical Choices & Reasoning

### Global State Management
Using `m.global` fields for cross-component communication. It works well for our relatively simple state needs:
- `allRowsData`: Master list of loaded photo rows
- `selectedPhotoData`: Currently viewed photo
- `isLoadingData`: Controls loading indicator visibility
- `navigateTo`: Triggers screen navigation

### Service Layer Pattern
The DataManager service separates business logic from UI code. This makes the components simpler and easier to test. MainScene just orchestrates, while DataManager handles the actual data fetching logic.

### Configuration-Driven Rows
All 14 photo categories are defined in `Config.brs`. Want to add a new category? Just add it to the config. The system automatically creates the UI and fetches the data.

## Trade-offs & What Could Be Better

### Things I Left Out

**Caching**: Currently, if you navigate between screens repeatedly, we don't cache photo data. Every detail view loads the image fresh. For a production app, I'd implement:
- LRU cache for recently viewed photos
- Disk caching for frequently accessed images
- Memory budget management

**Retry Logic**: When API calls fail, we just skip to the next category. A more robust solution would:
- Retry failed requests with exponential backoff
- Show user-friendly error messages for persistent failures
- Queue failed requests for retry when network returns

**Analytics**: No tracking of user behavior, popular categories, or error rates. Would be valuable for understanding usage patterns.

**Accessibility**: No voice navigation or screen reader support. Should be added for a production release.

### Different Approaches Considered

**Infinite Scroll vs. Pagination**: Went with lazy loading triggered by scroll position. An alternative would be explicit "Load More" buttons, but that felt clunky for a TV interface where users expect smooth browsing.

**Batch Size**: Tried 5 rows initially but it felt slow. 1 row was too aggressive on the API. 3 hit the sweet spot.

**Description Handling**: The scrollable description uses a timer-based focus approach. Considered alternatives like:
- Making the description non-focusable (loses scrolling)
- Using a custom scroll container (overkill for our needs)
- The timer approach is simple and works reliably

**Image Sizing**: Using Flickr's medium-sized images (500px). Could offer quality settings to let users choose higher resolution on fast connections, but that adds complexity for questionable benefit on TV screens.

## Running the Project

1. Ensure you have a Roku device set up
2. Enable developer mode on your Roku ( see roku doc)
3. Package and side-load the app via the Roku developer portal (access via your IP. You could also install the BRS language extension on VScode which can be used to easily sideload the app)
4. The app will fetch fresh photos from Flickr on each launch

## Project Structure

```
├── components/
│   ├── scene/
│   │   └── MainScene.brs          # Main controller
│   ├── screens/
│   │   ├── mainScreen/            # Gallery view
│   │   ├── detailsScreen/         # Photo detail view
│   │   └── splashScreen/          # Loading screen
│   ├── services/
│   │   └── DataManager.brs        # Business logic layer
│   ├── tasks/
│   │   └── FlickrImageTask.brs    # API integration
│   └── utils/
│       └── Config.brs             # App configuration
├── source/
│   └── Main.brs                   # Entry point
└── images/                        # App assets
```

## What I'd Do Differently for Production

1. **Testing**: Add unit tests for the DataManager and integration tests for the API layer. BrightScript doesn't have great testing tools, but there are frameworks available.

2. **Performance Monitoring**: Track image load times, API response times, and memory usage. Add logging to identify bottlenecks.

3. **User Preferences**: Let users mark favorite categories, save favorite photos, or adjust grid density.

4. **Search**: Add a search feature so users can find specific types of photos beyond the preset categories.

5. **Offline Support**: Cache popular categories so the app works (at least partially) without internet.

6. **Better Error UX**: Instead of silently failing, show subtle error indicators and offer retry options.

The current implementation prioritizes simplicity and reliability. It's a solid foundation that could be extended with any of these features as needed.
