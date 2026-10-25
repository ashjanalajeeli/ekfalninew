DO $$
BEGIN
  ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'charity';
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE TABLE IF NOT EXISTS charities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  license_number TEXT UNIQUE,
  phone TEXT,
  email TEXT,
  status TEXT NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS charity_members (
  charity_id UUID NOT NULL REFERENCES charities(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  membership_role TEXT NOT NULL DEFAULT 'manager',
  PRIMARY KEY (charity_id, user_id)
);

ALTER TABLE orphan_profiles ADD COLUMN IF NOT EXISTS charity_id UUID REFERENCES charities(id) ON DELETE SET NULL;
ALTER TABLE orphan_profiles ADD COLUMN IF NOT EXISTS gender TEXT;
ALTER TABLE orphan_profiles ADD COLUMN IF NOT EXISTS health_status TEXT;
ALTER TABLE orphan_profiles ADD COLUMN IF NOT EXISTS education_level TEXT;
ALTER TABLE orphan_profiles ADD COLUMN IF NOT EXISTS guardian_name TEXT;

CREATE TABLE IF NOT EXISTS projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  charity_id UUID NOT NULL REFERENCES charities(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  target_amount NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (target_amount >= 0),
  current_amount NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (current_amount >= 0),
  image_url TEXT,
  status TEXT NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS orphan_cases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  orphan_id UUID NOT NULL REFERENCES orphan_profiles(id) ON DELETE CASCADE,
  charity_id UUID NOT NULL REFERENCES charities(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  image_url TEXT,
  status TEXT NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TYPE sponsorship_request_status AS ENUM ('pending', 'approved', 'rejected', 'cancelled');
CREATE TABLE IF NOT EXISTS sponsorship_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  donor_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  orphan_id UUID NOT NULL REFERENCES orphan_profiles(id) ON DELETE CASCADE,
  charity_id UUID REFERENCES charities(id) ON DELETE SET NULL,
  monthly_amount NUMERIC(12,2) NOT NULL CHECK (monthly_amount > 0),
  status sponsorship_request_status NOT NULL DEFAULT 'pending',
  notes TEXT,
  reviewed_by UUID REFERENCES users(id),
  reviewed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE sponsorships ADD COLUMN IF NOT EXISTS request_id UUID UNIQUE REFERENCES sponsorship_requests(id);
ALTER TABLE sponsorships ADD COLUMN IF NOT EXISTS charity_id UUID REFERENCES charities(id) ON DELETE SET NULL;
CREATE UNIQUE INDEX IF NOT EXISTS uq_active_orphan_sponsorship ON sponsorships(orphan_id) WHERE status = 'active';

ALTER TABLE donations ADD COLUMN IF NOT EXISTS project_id UUID REFERENCES projects(id) ON DELETE SET NULL;

CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  donation_id UUID NOT NULL REFERENCES donations(id) ON DELETE CASCADE,
  provider TEXT NOT NULL,
  provider_reference TEXT,
  amount NUMERIC(12,2) NOT NULL,
  currency TEXT NOT NULL DEFAULT 'SAR',
  status TEXT NOT NULL DEFAULT 'pending',
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_id UUID REFERENCES users(id) ON DELETE SET NULL,
  action TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id UUID,
  details JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_charity_members_user ON charity_members(user_id);
CREATE INDEX IF NOT EXISTS idx_projects_charity_status ON projects(charity_id, status);
CREATE INDEX IF NOT EXISTS idx_requests_status_created ON sponsorship_requests(status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_payments_donation ON payments(donation_id);
CREATE INDEX IF NOT EXISTS idx_audit_entity ON audit_logs(entity_type, entity_id, created_at DESC);
