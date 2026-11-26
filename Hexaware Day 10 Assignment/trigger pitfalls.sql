-- =========================================================
-- Pitfalls and Limitations of Triggers
-- =========================================================

-- 1. Hidden Logic:
-- Triggers execute automatically in the background. Developers may
-- find it difficult to identify which trigger caused a database change.

-- 2. Cascading Effects:
-- One trigger may perform an operation that activates another trigger,
-- resulting in unexpected changes or complex execution flows.

-- 3. Performance Overhead:
-- Triggers execute whenever the specified database event occurs.
-- Complex triggers can slow down INSERT, UPDATE, and DELETE operations.

-- 4. Difficult Debugging:
-- Since triggers run automatically, identifying and fixing errors
-- can be more difficult than debugging normal SQL statements.

-- 5. Maintenance Complexity:
-- Trigger logic is stored separately inside the database, so developers
-- must remember to maintain it along with the application code.

-- 6. Limited Error Handling:
-- If a trigger encounters an error, the original database operation
-- may fail. This can affect the entire transaction.

-- 7. Testing Challenges:
-- Triggers must be tested separately for different situations,
-- including single-row updates, multiple-row updates, and invalid data.

-- 8. Business Logic Limitations:
-- Triggers are not ideal for complex workflows involving user
-- confirmation, manager approval, emails, or external services.


-- =========================================================
-- When Should We Avoid Triggers?
-- =========================================================

-- Avoid triggers:
-- 1. When the operation requires user interaction or approval.
-- 2. When complex business logic is easier to manage in application code.
-- 3. When frequent bulk operations may cause unnecessary performance overhead.
-- 4. When the logic needs to communicate with external applications or services.


-- =========================================================
-- Conclusion
-- =========================================================

-- Triggers are useful for automatic data validation, maintaining
-- consistency, and audit logging.
--
-- However, excessive use can make database operations difficult to
-- debug and maintain. Therefore, triggers should be used only when
-- automatic database-level execution is necessary.
