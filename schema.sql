CREATE TABLE public.accounts(id uuid PRIMARY KEY DEFAULT gen_random_uuid(),user_id uuid NOT NULL REFERENCES auth.users(id),name text NOT NULL);
CREATE TABLE public.transactions(id uuid PRIMARY KEY,user_id uuid NOT NULL REFERENCES auth.users(id),account_id uuid NOT NULL REFERENCES public.accounts(id),amount_cents bigint NOT NULL,category text NOT NULL,occurred date NOT NULL,updated_at timestamptz NOT NULL,deleted boolean NOT NULL DEFAULT false);
ALTER TABLE public.accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
CREATE POLICY accounts_owner ON public.accounts FOR ALL USING(auth.uid()=user_id) WITH CHECK(auth.uid()=user_id);
CREATE POLICY transactions_owner ON public.transactions FOR ALL USING(auth.uid()=user_id) WITH CHECK(auth.uid()=user_id AND EXISTS(SELECT 1 FROM public.accounts a WHERE a.id=account_id AND a.user_id=auth.uid()));
CREATE OR REPLACE FUNCTION public.apply_transaction(item jsonb) RETURNS void LANGUAGE plpgsql SECURITY INVOKER AS $$
BEGIN
 INSERT INTO public.transactions(id,user_id,account_id,amount_cents,category,occurred,updated_at,deleted)
 VALUES((item->>'id')::uuid,(item->>'user_id')::uuid,(item->>'account_id')::uuid,(item->>'amount_cents')::bigint,item->>'category',(item->>'occurred')::date,(item->>'updated_at')::timestamptz,(item->>'deleted')::boolean)
 ON CONFLICT(id) DO UPDATE SET amount_cents=EXCLUDED.amount_cents,category=EXCLUDED.category,occurred=EXCLUDED.occurred,updated_at=EXCLUDED.updated_at,deleted=EXCLUDED.deleted WHERE EXCLUDED.updated_at>transactions.updated_at;
END;$$;