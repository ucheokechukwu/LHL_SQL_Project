CREATE TABLE public.sales_report
(
    "productSKU" character varying(40),
    "total_ordered" integer,
    "name" character varying(100),
    "stockLevel" integer,
    "restockingLeadTime" integer,
    "sentimentScore" numeric(2, 1),
    "sentimentMagnitude" numeric(3, 1),
    "ratio" double precision
);

ALTER TABLE IF EXISTS public.sales_report
    OWNER to postgres;