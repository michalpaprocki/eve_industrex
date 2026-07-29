# EveIndustrex

EveIndustrex is a Phoenix/LiveView application for analyzing the EVE Online economy.

The project aggregates data from EVE's ESI API, continuously synchronizes market datasets, projects them into in-memory read models and serves interactive market analysis tools with millisecond response times.

## Features

- Continuous synchronization of ESI resources
- Automatic ETag and HTTP cache validation
- Route-aware ESI rate limiting
- Read-optimized ETS projections
- LiveView-based interactive tools
- Client-side price overrides with instant recalculation
- Historical synchronization metrics and telemetry

## Architecture

The application separates synchronization from querying.

```
        ESI API
           │
           ▼
   Synchronization Pipeline -------------┐
           │                             ▼
           |                     Dependency Discovery
           ▼                             |
 PostgreSQL (Write Model) ◀--------------┘
           │
           ▼
    Projection Engine
           │
           ▼
    ETS (Read Model)
           │
           ▼
    Domain Services
           │
           ▼
   Phoenix LiveView
```

External data is first synchronized into PostgreSQL, then projected into immutable ETS tables optimized for reads. LiveViews never query the write model directly, allowing complex market calculations to remain responsive even while large synchronizations are in progress.

## Synchronization

The synchronization engine supports:

- paginated resources
- non-paginated resources
- conditional requests (ETags)
- generation tracking
- retry and backoff
- route-aware rate limiting
- projection triggering after successful synchronization

## Current data sources

- Market Orders
- Average Prices
- Industry System Cost Indices

Additional ESI resources can be added by implementing a fetch function and projection.

## Technology

- Elixir
- Phoenix LiveView
- PostgreSQL
- ETS
- Oban
- Ecto

## Why this project?

The project started as a market analysis tool for EVE Online but gradually evolved into an experiment in designing read-optimized systems around external APIs.

Many of the architectural decisions were driven by ESI constraints such as pagination, caching semantics, asynchronous updates and strict rate limiting.
