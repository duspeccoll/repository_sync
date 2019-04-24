ArchivesSpace::Application.routes.draw do
  match('/plugins/repository_sync' => 'repository_sync#index', :via => [:get])
  match('/plugins/repository_sync/search' => 'repository_sync#search', :via => [:post])
  match('/plugins/repository_sync/:id/download' => 'repository_sync#download', :via => [:get])
end
