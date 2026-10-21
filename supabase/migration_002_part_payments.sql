-- Run once in Supabase > SQL Editor (allows part payments, fines and notes).
alter table loan_payments add column if not exists fine numeric not null default 0;
alter table loan_payments add column if not exists note text;
alter table loan_payments drop constraint if exists loan_payments_loan_id_month_index_key;
