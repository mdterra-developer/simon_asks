module SimonAsks
  class AnswerCommentsController < SimonAsks::ApplicationController

    authorize_resource class: false

    before_filter :find_question
    before_filter :find_answer, except: [:update]
    before_filter :find_comment, except: [:create]

    def create
      @comment = @answer.comments.build(params[:comment])
      @comment.user = current_user
      if @comment.save
        respond_to do |format|
          format.html { redirect_to @question, notice: t.comment.was.created }
          format.js
        end
      else
        respond_to do |format|
          format.html { render 'questions/show' }
          format.js { render js: "$('.answer##{@answer.id} .add_answer_comment.loader').hide(); $('.answer##{@answer.id} .add_answer_comment_block').show();" }
        end
      end
    end

    def edit
    end

    def update
      if @comment.update_attributes(params[:comment])
        redirect_to question_path(@question), notice: t.comment.was.updated
      else
        render :edit
      end
    end

    def destroy
      if @comment.destroy
        respond_to do |format|
          format.html { redirect_to @question, notice: t.comment.was.destroyed }
          format.js { render js: "$('.comment-item##{@comment.id}').html('<div class=\"destroyed\">#{t.comment.was.destroyed}</div>');" }
        end
      else
        respond_to do |format|
          format.html { redirect_to @question }
          format.js { render js: "$('.comment-item##{@comment.id}').show();" }
        end
      end
    end

    private

    def find_question
      @question = Question.find(params[:question_id])
    end

    def find_answer
      @answer = QuestionAnswer.find(params[:answer_id])
    end

    def find_comment
      @comment = Comment.find(params[:id])
    end
  end
end