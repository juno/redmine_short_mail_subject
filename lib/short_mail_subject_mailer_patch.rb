require_dependency 'mailer'

module ShortMailSubjectMailerPatch
  def self.included(base)  # :nodoc:
    base.send(:include, InstanceMethods)

    base.class_eval do
      alias_method_chain :issue_add, :short
      alias_method_chain :issue_edit, :short
      alias_method_chain :document_added, :short
      alias_method_chain :attachments_added, :short
      alias_method_chain :news_added, :short
      alias_method_chain :message_posted, :short
    end
  end

  module InstanceMethods
    def issue_add_with_short(issue)
       redmine_headers 'Project' => issue.project.identifier,
                       'Issue-Id' => issue.id,
                       'Issue-Author' => issue.author.login
       redmine_headers 'Issue-Assignee' => issue.assigned_to.login if issue.assigned_to
       recipients issue.recipients
       cc(issue.watcher_recipients - @recipients)
       subject "[#{issue.project.identifier} ##{issue.id}] #{issue.subject}"
       body :issue => issue,
            :issue_url => url_for(:controller => 'issues', :action => 'show', :id => issue)
    end

    def issue_edit_with_short(journal)
      issue = journal.journalized
      redmine_headers 'Project' => issue.project.identifier,
                      'Issue-Id' => issue.id,
                      'Issue-Author' => issue.author.login
      redmine_headers 'Issue-Assignee' => issue.assigned_to.login if issue.assigned_to
      @author = journal.user
      recipients issue.recipients
      # Watchers in cc
      cc(issue.watcher_recipients - @recipients)
      subject "[#{issue.project.identifier} ##{issue.id}]"
      body :issue => issue,
           :journal => journal,
           :issue_url => url_for(:controller => 'issues', :action => 'show', :id => issue)
    end

    def document_added_with_short(document)
      redmine_headers 'Project' => document.project.identifier
      recipients document.project.recipients
      subject "[#{document.project.identifier}] #{l(:label_document_new)}: #{document.title}"
      body :document => document,
           :document_url => url_for(:controller => 'documents', :action => 'show', :id => document)
    end

    def attachments_added_with_short(attachments)
      container = attachments.first.container
      added_to = ''
      added_to_url = ''
      case container.class.name
      when 'Project'
        added_to_url = url_for(:controller => 'projects', :action => 'list_files', :id => container)
        added_to = "#{l(:label_project)}: #{container}"
      when 'Version'
        added_to_url = url_for(:controller => 'projects', :action => 'list_files', :id => container.project_id)
        added_to = "#{l(:label_version)}: #{container.name}"
      when 'Document'
        added_to_url = url_for(:controller => 'documents', :action => 'show', :id => container.id)
        added_to = "#{l(:label_document)}: #{container.title}"
      end
      redmine_headers 'Project' => container.project.identifier
      recipients container.project.recipients
      subject "[#{container.project.identifier}] #{l(:label_attachment_new)}"
      body :attachments => attachments,
           :added_to => added_to,
           :added_to_url => added_to_url
    end

    def news_added_with_short(news)
      redmine_headers 'Project' => news.project.identifier
      recipients news.project.recipients
      subject "[#{news.project.identifier}] #{l(:label_news)}: #{news.title}"
      body :news => news,
           :news_url => url_for(:controller => 'news', :action => 'show', :id => news)
    end

    def message_posted_with_short(message, recipients)
      redmine_headers 'Project' => message.project.identifier,
                      'Topic-Id' => (message.parent_id || message.id)
      recipients(recipients)
      subject "[#{message.board.project.identifier} - #{message.board.name}] #{message.subject}"
      body :message => message,
           :message_url => url_for(:controller => 'messages', :action => 'show', :board_id => message.board_id, :id => message.root)
    end
  end
end
