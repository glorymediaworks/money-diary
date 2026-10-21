-- Money Diary, Phase 1 (loans, EMIs, credit cards). Run once in Supabase > SQL Editor.
create table if not exists loans(id uuid primary key default gen_random_uuid(), user_id uuid not null default auth.uid(), name text not null, lender text, loan_number text, amount numeric not null, emi numeric not null, months int not null, first_emi_date date not null, autopay_bank text, created_at timestamptz default now());
create table if not exists loan_payments(id uuid primary key default gen_random_uuid(), user_id uuid not null default auth.uid(), loan_id uuid not null references loans(id) on delete cascade, month_index int not null, paid_on date, amount numeric not null, fine numeric not null default 0, note text, bank_txn_id uuid);
create table if not exists loan_docs(id uuid primary key default gen_random_uuid(), user_id uuid not null default auth.uid(), loan_id uuid not null references loans(id) on delete cascade, name text not null, path text not null, created_at timestamptz default now());
create table if not exists cards(id uuid primary key default gen_random_uuid(), user_id uuid not null default auth.uid(), name text not null, bank text, last4 text, credit_limit numeric default 0, due_day int default 1, created_at timestamptz default now());
create table if not exists card_bills(id uuid primary key default gen_random_uuid(), user_id uuid not null default auth.uid(), card_id uuid not null references cards(id) on delete cascade, month date not null, amount numeric not null default 0, paid_on date, bank_txn_id uuid, unique(card_id, month));
do $$ declare t text; begin
foreach t in array array['loans','loan_payments','loan_docs','cards','card_bills'] loop
execute format('alter table %I enable row level security', t);
execute format('drop policy if exists own_rows on %I', t);
execute format('create policy own_rows on %I for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid())', t);
end loop; end $$;
insert into storage.buckets(id,name,public) values ('loan-docs','loan-docs',false) on conflict do nothing;
drop policy if exists own_docs on storage.objects;
create policy own_docs on storage.objects for all to authenticated using (bucket_id='loan-docs' and (storage.foldername(name))[1]=auth.uid()::text) with check (bucket_id='loan-docs' and (storage.foldername(name))[1]=auth.uid()::text);
