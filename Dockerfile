 > [stage-0  7/11] RUN pnpm install:
0.672  ERR_PNPM_NO_PKG_MANIFEST  No package.json found in /src/app/memos/web
------
Dockerfile:26
--------------------
  24 |     # -------------------------
  25 |     WORKDIR /src/app/memos/web
  26 | >>> RUN pnpm install
  27 |     RUN pnpm run build
  28 |     
--------------------
ERROR: failed to build: failed to solve: process "/bin/sh -c pnpm install" did not complete successfully: exit code: 1
Error: Process completed with exit code 1.
