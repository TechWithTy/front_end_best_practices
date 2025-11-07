# Vitest + React Testing Library Mocking Guide
Browse: [https://medium.com/@andrewjeremy12345/the-secret-sauce-to-lightning-fast-react-tests-vitest-react-testing-library-e96be5c04b92](https://medium.com/@andrewjeremy12345/the-secret-sauce-to-lightning-fast-react-tests-vitest-react-testing-library-e96be5c04b92)

Last updated: 2025-11-07

## Why Mocking Matters
- Keeps React/Next tests fast by avoiding real network or browser APIs.
- Removes flakiness from rate limits or inconsistent backends.
- Focuses assertions on UI behaviour instead of infrastructure noise.

## Tooling Setup
```sh
pnpm add -D vitest @testing-library/react @testing-library/jest-dom @testing-library/user-event msw
```
- Enable `environment: 'jsdom'` inside `vitest.config.ts` for DOM APIs.
- Register `@testing-library/jest-dom` in `setupFiles` to use matchers like `toBeInTheDocument`.

## Mocking Global APIs
- Use `vi.stubGlobal` for unsupported browser APIs (e.g., `IntersectionObserver`).
```ts
import { vi } from "vitest";

const intersectionObserverMock = vi.fn(() => ({
	disconnect: vi.fn(),
	observe: vi.fn(),
	takeRecords: vi.fn(),
	unobserve: vi.fn(),
}));

vi.stubGlobal("IntersectionObserver", intersectionObserverMock);
```

## Module Mocking Patterns
- Declare mocks once at the top level using `vi.mock`.
- Prefer `vi.hoisted` when mocks need to be defined before `vi.mock` executes.
```ts
const { mockUseParams } = vi.hoisted(() => ({
	mockUseParams: vi.fn(),
}));

vi.mock("@tanstack/react-router", async () => {
	const actual = await vi.importActual<typeof import("@tanstack/react-router")>("@tanstack/react-router");
	return {
		...actual,
		useParams: mockUseParams,
	};
});
```
- Within individual tests, call `mockUseParams.mockReturnValueOnce(value)` for per-case overrides.

## API Mocking with MSW
- Intercept fetch/XHR requests to guarantee stable responses.
```ts
import { http, HttpResponse } from "msw";
import { mswServer } from "@/lib/msw";

mswServer.use(
	http.get("/api/users", () =>
		HttpResponse.json({ users: [{ id: 1, name: "Ada" }] }, { status: 200 }),
	),
);
```
- Start the MSW server in `setupTests.ts` and reset handlers after each test.

## Component Test Example
```ts
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import UserList from "./UserList";

vi.stubGlobal("fetch", vi.fn(async () => ({
	json: async () => [
		{ id: 1, name: "Charlie" },
		{ id: 2, name: "Diana" },
	],
})));

describe("<UserList />", () => {
	it("renders users and handles reload", async () => {
		render(<UserList />);

		await waitFor(() => {
			expect(screen.getByText("Charlie")).toBeInTheDocument();
		});

		(fetch as unknown as vi.Mock).mockResolvedValueOnce({
			json: async () => [{ id: 3, name: "Eve" }],
		});

		await userEvent.click(screen.getByText("Reload"));

		await waitFor(() => {
			expect(screen.getByText("Eve")).toBeInTheDocument();
		});
	});
});
```

## Testing Workflow Checklist
- `pnpm test:pwa` or `pnpm vitest` to run fast unit suites.
- Ensure mocks live beside domain logic (e.g., `__mocks__/env.ts`).
- Reset mocks with `vi.clearAllMocks()` inside `afterEach` to avoid bleed.
- Combine MSW with `waitForNoLoadingOverlay`-style utilities for async UIs.

## Notes for Deal Scale
- Mirror this setup in Next.js `app/` tests: keep mocks central in `lib/testing/`.
- Hoist router mocks to keep deep-linked dashboards predictable.
- Use MSW to simulate analytics/push APIs without hitting real infra.
