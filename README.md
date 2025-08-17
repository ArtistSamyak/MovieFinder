# 🎬 Movie Finder Application

## 1. Introduction
Movie Finder is an iOS application built as part of a technical assessment. It demonstrates **MVVM architecture** within a **Clean Architecture** structure. The app consumes the [TMDb API](https://www.themoviedb.org/documentation/api) to provide search and discovery of movies with elegant UI, caching, and modular navigation.




https://github.com/user-attachments/assets/ff8fcd71-41d0-4496-b013-66cbfea94291




---

## 2. Architectural Decisions

<img width="3456" height="2054" alt="classDiagram" src="https://github.com/user-attachments/assets/edabc5aa-614c-419f-b254-d73c4396765d" />


The codebase is divided into three layers: **Presentation**, **Domain**, and **Data** — each with distinct responsibilities.

### 2.1 Presentation Layer (UIKit)
- Implemented with **UIKit**.
- Follows the **MVVM pattern** with delegation for communication.
- Each `View` has a corresponding `ViewModel`.
- Navigation and dependency injection are handled by a **Flow Coordinator** using the factory pattern.

### 2.2 Domain Layer (Business Logic)
- Contains **entities**, **use cases**, and **repository protocols**.
- Business rules are encapsulated inside **Use Cases**, separate from UI and networking.
- Repository interfaces are defined here; the Data layer provides implementations.

### 2.3 Data Layer (Networking & Persistence)
- Networking implemented with **async/await**.
- **Network Service** fetches movie data from TMDb.
- **Core Data** is used for persistence and caching.
- An **Image Repository** manages downloading and caching of poster images.

---

## 3. Caching Mechanism
- Recently viewed movies are cached in **Core Data**.
- On app launch, a list of up to **10 most recently viewed** movies is displayed.
- Cache policy:
  - Most recently viewed appears first.
  - Oldest entry is evicted once limit is reached.
  - Cache size is configurable.

---

## 4. Networking Implementation
- Network Service performs all API requests.
- Designed with **dependency injection** for testability and flexibility.
- Error handling provides clear, user-friendly messages.

---

## 5. Flow Coordinator (Navigation)
- Centralizes navigation and dependency wiring.
- Acts as a **factory** for constructing the Search and Detail screens.
- Decouples UI logic from navigation concerns, keeping modules independent.

---

## 6. Setup Instructions

### 6.1 Prerequisites
- **Xcode 14** or later  
- **macOS 12** or later  
- **Swift 5.5** or later
- **iOS 16** or later  

### 6.2 Installation & Running the App
1. Clone the repository:
   ```bash
   git clone https://github.com/ArtistSamyak/MovieFinder.git
   cd MovieFinder
2. Open APIEndpoints.swift:
   ```bash
   static let apiKey = "REPLACE_WITH_YOUR_TMDB_API_KEY"


