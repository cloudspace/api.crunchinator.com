# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
ZipCodeGeo.import_from_csv

# Categories have display names that crunchbase doesn't have in their api.  We have to map them here.
display_names = {
  advertising: 'Advertising',
  analytics: 'Analytics/Big Data',
  design: 'Art/Design',
  automotive: 'Automotive',
  biotech: 'BioTech',
  nonprofit: 'Charity/Nonprofit',
  cleantech: 'CleanTech',
  consulting: 'Consulting',
  hardware: 'Consumer Electronics/Devices',
  web: 'Consumer Web',
  ecommerce: 'eCommerce',
  education: 'Education',
  enterprise: 'Enterprise',
  fashion: 'Fashion/Clothing',
  finance: 'Finance/Venture',
  games_video: 'Games/Entertainment',
  government: 'Government',
  health: 'Health/Fitness',
  hospitality: 'Hospitality/Food',
  legal: 'Legal',
  local: 'Local Business',
  manufacturing: 'Manufacturing',
  medical: 'Medical',
  messaging: 'Messaging',
  mobile: 'Mobile/Wireless',
  music: 'Music',
  nanotech: 'Nanotech',
  network_hosting: 'Network/Hosting',
  news: 'News/Media',
  pets: 'Pets',
  photo_video: 'Photo/Video',
  public_relations: 'Public Relations',
  real_estate: 'Real Estate',
  search: 'Search',
  security: 'Security',
  semiconductor: 'Semiconductor',
  social: 'Social Networking',
  software: 'Software',
  sports: 'Sports',
  transportation: 'Transportation',
  travel: 'Travel',
  other: 'Other'
}

display_names.each do |key, display_name|
  Category.find_or_create_by(name: key).update_attributes(display_name: display_name)
end
