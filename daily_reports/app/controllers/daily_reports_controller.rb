class DailyReportsController < ApplicationController
   unloadable

   before_filter :find_project, :authorize

   helper :issues

   def index
      trackers = @project.trackers
      @users = @project.users
      @user = User.find_by_id(params[:user_id]) if params[:user_id]
      begin
         @date = Date.parse(params[:date].to_s)
      rescue
         @date = Date.today
      end
      #@date = params[:date].nil? ? Date.today : params[:date].blank? ? Date.today : params[:date].to_s.to_date
      if @user
         @show_prev = (params[:show_prev].nil?) ? false :(params[:show_prev] == '1')
         # fill trackers
         @trackers = []
         trackers.each do |tracker|
            issues = Issue.where(:assigned_to_id => @user.id, :tracker_id => tracker.id)
            # fill history
            history = []
            issues.each do |issue|
               journal = Journal.where("journalized_id = :issue_id AND journalized_type = :type", \
                  {:issue_id => issue.id, :type => "Issue"}).order("created_on DESC")
               journal = filter_journal(journal)
               spent = TimeEntry.where("project_id = :project_id AND issue_id = :issue_id AND spent_on <= :spent_on", \
                  {:project_id => @project.id, :issue_id => issue.id, :spent_on => @date.to_s}).order("spent_on DESC")
               spent = group_spent(spent)
               history << {:issue => issue, :journal => journal, :spent => spent}
            end
            @trackers << {:tracker => tracker, :history => history}
         end
      else
         @show_prev = true
      end
   end
   
   def group_spent(spent)
      tmp_prev = (@date - 1.days).to_s

      new_spent = []
      @users.each do |user|
         tmp_spent = nil
         
         spent.each do |entry|
            if entry.user_id == user.id
               tmp_spent = entry
               break
            end
         end
         
         next unless tmp_spent
         
         tmp_date = tmp_spent.spent_on.to_s

         user_spent_list = []
         time = 0
         spent.each do |entry|
            if entry.spent_on.to_s == tmp_date && entry.user_id == user.id
               user_spent_list << entry
               time += entry.hours
            end
         end
         
         new_spent << {:user => user, :date => tmp_date, :time => time, :spent => user_spent_list} if user_spent_list.count > 0

         if @show_prev && tmp_prev != tmp_date
            user_spent_list = []
            time = 0
            spent.each do |entry|
               if entry.spent_on.to_s == tmp_prev && entry.user_id == user.id
                  user_spent_list << entry
                  time += entry.hours
               end
            end
            
            new_spent << {:user => user, :date => tmp_prev, :time => time, :spent => user_spent_list} if user_spent_list.count > 0
         end
      end
      
      new_spent.sort! {|a, b| [a[:user].id == @user.id ? 0 : 1, b[:date]] <=> [b[:user].id == @user.id ? 0 : 1, a[:date]] }
      
      return new_spent
   end
   
   def filter_journal(journal)
      journal.each do |j|
         unless j.notes.blank?
            return [j]
         end
      end
      
      return []
   end
end
