CREATE TABLE public.sales_by_sku
(
    "productSKU" character varying(40),
    "total_ordered" integer
)

ALTER TABLE IF EXISTS public.sales_by_sku
    OWNER to postgres;