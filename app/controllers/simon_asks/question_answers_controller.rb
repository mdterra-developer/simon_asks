module SimonAsks
  class QuestionAnswersController < SimonAsks::ApplicationController

    authorize_resource

    before_filter :find_answer_by_id, only: [:edit, :update, :destroy]
    before_filter :find_answer_by_answer_id, only: [:upvote, :downvote]

    def create
      @question = Question.find(params[:question_id])
      @answer = QuestionAnswer.new(params[:question_answer])
      @answer.question = @question
      @answer.user = current_user
      if @answer.save
        respond_to do |format|
          format.html { redirect_to question_path(@question), notice: t.answer.was_created }
          format.js
        end
      else
        respond_to do |format|
          format.html { render 'questions/show' }
          format.js { render js: "$('#add_answer.loader').hide(); $('#add_answer_block').show();" }
        end
      end
    end

    def edit
      redirect_to question_path(@answer.question) unless @answer.can_edit?(current_user)
    end

    def update
      if @answer.update_attributes(params[:question_answer])
        redirect_to question_path(@answer.question), notice: t.answer.was_updated
      else
        render :edit
      end
    end

    def upvote
      unless current_user && @answer.user == current_user && current_user.voted_down_on?(@answer) != true
        if current_user.voted_up_on? @answer
          @answer.unvote :voter => current_user, :vote => 'like'
          @minus = 1
        else
          @answer.vote :voter => current_user, :vote => 'like'
        end
      else
        @error = 1
      end
    end

    def downvote
      unless current_user && @answer.user == current_user && current_user.voted_up_on?(@answer) != true
        if current_user.voted_down_on? @answer
          @answer.unvote :voter => current_user, :vote => 'bad'
          @minus = 1
        else
          @answer.vote :voter => current_user, :vote => 'bad'
        end
      else
        @error = 1
      end
    end

    def destroy
      @question = Question.find(params[:question_id])
      @answer.destroy
      redirect_to question_path(@question)
    end

    private

    def find_answer_by_id
      @answer = QuestionAnswer.find(params[:id])
    end

    def find_answer_by_answer_id
      @answer = QuestionAnswer.find(params[:answer_id])
    end
  end
end