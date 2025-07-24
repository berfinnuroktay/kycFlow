# KYC Flow: Dynamic Form System

This project is a native iOS application that implements a dynamic "Know Your Customer" (KYC) form system. It can render and validate forms based on country-specific JSON configurations and handles special requirements for different regions.

## How to Run

- Open the `.xcodeproj` file in Xcode.
- Select a target simulator or a physical device.
- Run the application (Product > Run or `Cmd+R`).

## Solution Architecture

The application is built using SwiftUI and follows modern architectural principles, emphasizing separation of concerns and a data-driven UI.

- **`ConfigurationManager`**: This `ObservableObject` is responsible for loading and decoding all JSON configuration files (`Manifest.json` and country-specific files) at launch. It is responsible for data handling for country configurations.
- **`AppRouter`**: Navigation manager which allows us to handle navigation at a higher level. It can be further improved by adding `pop`, `push` functions to create an intuitive navigation handling. This decouples views from direct navigation logic.
- **MVVM (Model-View-ViewModel)**: The form itself is structured using the MVVM pattern.
    - **`FormView`  (View)**: The SwiftUI view that renders the form fields and buttons. It is state-driven and reacts to changes in its ViewModel.
    - **`FormViewModel`  (ViewModel)**: Manages the state for the entire form, including item viewModels, handling submission logic, and coordinating data fetching for special cases.
     -   **`FormFieldItemViewModel`**: An item viewModel for each field in the form (`TextField`,  `DatePicker`, etc.). It allows full control over the state of the field by separating responsibilities from `FormViewModel`.
 - **Dependency Injection**: Dependencies are explicitly passed into objects that need them. For instance, the `FormViewModel`is initialized with a `UserProfileFetcherFactory`.

## NL-Specific Behavior Implementation

The assignment required a special flow for the Netherlands (NL), where user data is fetched from a mocked API instead of being entered manually.

## NL-Specific Behavior Implementation

The assignment required a special flow for the Netherlands (NL), where user data is fetched from a mocked API instead of being entered manually.

### Architectural Approach: The Factory Pattern

To handle this without further complicating the  `FormViewModel`  with country-specific  `if/else`  statements, a  **Factory**  pattern was used.

1.  **`UserProfileFetcher`  Protocol**: A simple protocol was defined to abstract the action of fetching a user profile.
    
2.  **`MockNLProfileFetcher`**: An implementation of the fetcher protocol that simulates a network call and returns hardcoded data for the Netherlands.
    
3.  **`UserProfileFetcherFactory`**: When the  `FormViewModel`  is initialized, it asks the factory to create a fetcher for the selected country code. The factory contains the country-specific logic, returning a  `MockNLProfileFetcher`  only if the country code is "NL" and  `nil`  otherwise. This allows us to handle new cases in the event of adding new special cases for other countries.
    

This approach cleanly isolates the special-case logic within the factory. The  `FormViewModel`  remains agnostic; it only knows whether it received a fetcher object or not. If it did, it uses it to fetch and pre-fill the data, setting the fields to a read-only state.

## Recommended Config Improvements

The current configuration format works well, but it lacks metadata to handle UI behavior like data pre-filling. To support such features more explicitly in the future, I would propose adding an optional

`dataSource`  object to the field configuration.

**Proposed YAML/JSON Structure:**

JSON

```
# ... other fields
{
    "id": "first_name",
    "label": "First Name",
    "type": "text",
    "required": true,
    "dataSource": {
        "sourceType": "api",
        "endpoint": "/api/nl-user-profile",
        "readOnly": true
    }
}

```

**Benefits of this approach:**

-   **Explicit & Declarative**: The configuration file would clearly state the fields source, saving the application from handling this logic internally.
    
-   **Scalable**: The  `FormViewModel`  could be enhanced to parse this  `dataSource`  object and dynamically create the appropriate fetcher without needing a country-specific factory. This would make adding new pre-filled forms for other countries possible simply by changing the configuration, with no code changes required.
    
-   **Flexible**: The  `sourceType`  could be expanded in the future to support other sources.
