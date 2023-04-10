CREATE TABLE public.products
(
    "SKU" character varying(40),
    "name" character varying(100),
    "orderedQuantity" integer,
    "stockLevel" integer,
    "restockingLeadTime" integer,
    "sentimentScore" numeric(2, 1),
    "sentimentMagnitude" numeric(3, 1)
);

ALTER TABLE IF EXISTS public.products
    OWNER to postgres;