# Riqqi-priority merge design

## Scope

Integrate `riqqi15/dev1-riyadh` into local `Brandon-Dev2`, which already contains `mjohan24/MJohan-Dev3`. This is a local Git merge only; do not push or deploy.

## Conflict policy

Riqqi's assistant voice, station location, and timetable behavior wins when the branches disagree. Retain MJohan's backend benchmark, request timing, cache, and read-model optimizations where they remain compatible. Do not retain MJohan's competing wake-word flow merely to satisfy a merge; it can be revisited separately.

## Integration and verification

Resolve conflicts against Riqqi's behavior, then compile and run available tests. Repair integration errors without changing production data or credentials. Keep database-dependent tests distinct from code failures. Confirm both branch tips are ancestors of the final merge commit, and leave the working tree clean.

## Boundaries

No remote push, Render deployment, production benchmark, database mutation, or secret disclosure. These require separate verification and, where applicable, access to the deployed service.
