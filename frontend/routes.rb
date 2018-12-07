ArchivesSpace::Application.routes.draw do
  match('/plugins/repository_sync/:id/download' => 'repository_sync#download', :via => [:get])
end
