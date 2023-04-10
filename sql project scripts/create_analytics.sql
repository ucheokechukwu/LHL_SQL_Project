CREATE TABLE public.analytics
(
    "visitNumber" integer,
    "visitId" integer,
    "visitStartTime" integer,
    "date" date,
    "fullvisitorId" character varying(40),
    "userid" character varying(40),
    "channelGrouping" character varying(40),
    "socialEngagementType" character varying(40),
    "units_sold" integer,
    "pageviews" integer,
    "timeonsite" integer,
    "bounces" integer,
    "revenue" bigint,
    "unit_price" bigint
);

ALTER TABLE IF EXISTS public.analytics
    OWNER to postgres;