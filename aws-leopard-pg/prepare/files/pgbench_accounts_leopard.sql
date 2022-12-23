CREATE EXTENSION leopard;

DROP TABLE public.pgbench_accounts;

CREATE TABLE public.pgbench_accounts (
  aid INTEGER NOT NULL,
  bid INTEGER,
  abalance INTEGER,
  filler CHAR(84)
) USING leopard;
