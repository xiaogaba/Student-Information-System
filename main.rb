require 'sinatra'
require 'sass'
require 'dm-core'
require 'dm-migrations'

DATABASE_URL=ENV['DATABASE_URL']
DataMapper.setup(:default, DATABASE_URL)

# set up student model
class Student
  include DataMapper::Resource
  property :id, Serial
  property :firstname, String
  property :lastname, String
  property :birthday, Date
  property :address, String
  property :studentID, String
end

#set up comment model
class Comment
  include DataMapper::Resource
  property :id, Serial
  property :subject,String
  property :posted_by, String
  property :body, Text
  property :created_at,DateTime 
end

DataMapper.finalize
DataMapper.auto_migrate!


Student.create(:firstname => "Emma", :lastname => "Xu",:address => "147 Angus Road, New York, NY 10003")
Student.create(:firstname => "Elnora", :lastname => "Song",:address => "1474 Marshall Street, Baltimore, MD 21202")
Comment.create(:subject => "no subject",:posted_by => "xin", :body => "very good", :created_at => Time.now)

# home
get '/' do
  @title = "sinatra song page"
  @comments = Comment.all
  erb :home
end

#login
get '/login' do
  erb :form
end

post '/login' do
  p "got post login"
  p "param: #{params[:username]}, #{params[:password]}"
  p "set: #{settings.username}, #{settings.password}"
  if params[:username] == settings.username && params[:password] == settings.password
    p "in"
    session[:admin] = true
    @admin = true
    redirect '/students'
  else
    p "out"
    @error = true
    erb :form
  end
end

#about
get '/about' do
  @title = "sinatra song page"
  erb :about
end

#contact
get '/contact' do
  @title = "sinatra song page"
  erb :contact
end

# show comments
get '/comment' do
  @comments=Comment.all
  erb :comments
end

# show comment detail
get '/comment/:id' do
  @comments=Comment.all
  @comments.each do |comment|
    if comment[:id] == params[:id].to_i
      @selected = comment
    end
  end
  
  erb :single_comment
end

# create new comments
post '/add_comments' do
  if(params[:subject].empty?)
    subject = "No subject"
  else 
    subject = params[:subject]
  end
  if(params[:posted_by].empty?)
    author = "Anonymous user"
  else
    author = params[:posted_by]
  end
  content = params[:body]
  created_at = Time.now.utc
  @comments = Comment.all
  if(content.empty?)
    erb :comment_fail
  else
    Comment.create(:subject => subject, :posted_by => author, :body => content,:created_at => created_at)
    erb :comments
  end
end


get '/style.css' do
  scss :style
end

# create new student 
get '/add_students' do
  halt(401, 'Not Authorized') unless session[:admin]
  erb :student_form
end

post '/add_students' do
  firstname = params[:firstname]
  lastname = params[:lastname]
  birthday = params[:birthday]
  address = params[:address]
  studentID = params[:studentID]
  @students = Student.all
  if(firstname.empty?||lastname.empty?||birthday.empty?||address.empty?||studentID.empty?)
    erb :fail
  else
    Student.create(:firstname => firstname, :lastname => lastname, :birthday => birthday,:address => address, :studentID => studentID)
    erb :success
  end
end

# show students information
get '/students' do
  #puts "Got song"
  @students = Student.all
  erb :students
end

# add new comment
get '/add_comments' do
  erb :comment_form
end

# edit student information

get('/add_students/:id/edit') do
  halt(401, 'Not Authorized') unless session[:admin]
   @students = Student.all
   @students.each do |student|
    if student[:id] == params[:id].to_i
      @selected = student
    end
  end
  erb :student_form_edit
end
  
put('/add_students/:id') do
  student = Student.get(params[:id])
  student.firstname = params[:firstname]
  student.lastname = params[:lastname]
  student.birthday = params[:birthday]
  student.address = params[:address]
  student.studentID = params[:studentID]
  student.save
  redirect'/students'
  end

# show student detail information
get '/student/:id' do
  @students = Student.all
  @students.each do |student|
    if student[:id] == params[:id].to_i
      @selected_student = student
    end
  end
  erb :single_student
end

# delete student
get '/delete_student/:id' do
  halt(401, 'Not Authorized. Please login!') unless session[:admin]
    Student.get(params[:id]).destroy
    redirect '/students'
end

configure do
  enable :sessions
  set :username, "xin"
  set :password, "he"
end

get '/video' do
  erb :video
end

get '/logout' do
  session.clear
  @admin = false
  "logging out......"
  redirect to '/login'
end



