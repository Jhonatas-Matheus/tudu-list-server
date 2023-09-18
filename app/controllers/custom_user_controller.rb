class CustomUserController < ApplicationController
    def find_by_email
        puts(params[:email])
        email = params[:email]

        user = User.find_by(email: email)

        if user
        render json: user
        else
        render json: { error: 'Usuário não encontrado' }, status: :not_found
        end
    end
end