#!/usr/bin/ruby
#************************************************************
#File:		regex_check.rb	
#Version:	1.0
#Author:	lijiashu <broadskyer@gmail.com>
#			Copyright (c) lijiashu @BUPT
#Date:		Wed 16 Jan 2013 11:43:15 PM CST
#brief:	    Check regex.
#Description: 
#***********************************************************
#history:
#***********************************************************
require 'csv'
#===========================================================
# Class:	HostRegex
# Utility:	regex验证类。验证CSV文件中的正则表达式是否正确，
#			并输出错误统计结果。
# ==========================================================
class HostRegex
	#-------------------------------------------------------
	# Function: 构造函数
	# Input:	NONE
	# Output:	NONE
	#-------------------------------------------------------
	def initialize							
		@capture_string = Array.new				#初始化文本捕获数组capture_string
		@capture_number = Array.new				#初始化数字捕获数组capture_number
		@wr_url = 0								#统计出错的url_regex
		@wr_title = 0							#统计出错的title_regex
		@wr_keywords = 0						#统计出错的keywords_regex
		@wr_description = 0						#统计出错的description_regex
	end

	#-------------------------------------------------------
	# Function:	验证CSV文件中的文本-正则对。 
	# Input:	CSV文件	
	# Output:   NONE
	#-------------------------------------------------------
    def check(file)								#checking 入口
		i = 0	
        CSV.open(file, "r").each do |record|
			i += 1
			if i > 1 then						#跳过csv文件的第一行
				check_core( record, i)			#验证正则表达式的核心函数
			end
        end
		statics()								#数据统计并打印
    end

	#-------------------------------------------------------
	# Function: 验证kewords的正则表达式
	# Input:	title的捕获文本，csv记录，csv记录编号	
	# Output:	NONE
	#-------------------------------------------------------
	def check_keywords(capture_string, record, index)	
		#puts "==== Keywords ===="
		if record[6] == "\\static" || record[6] == "\\null" then
		else
			begin
				#puts "record[6]: #{record[6]}"
				record[6].strip!							#去除regex两端空格
				tmp_record6 = record[6]
				a = record[6].scan(/\\(\d)/)				#捕获regex中的\num，用以恢复regex
				@capture_number = Array.new(a)
				#puts "capture_number: #{@capture_number}"
				#puts "capture_string: #{@capture_string}"
				for i in 0..(@capture_number.length - 1)
					if @capture_string[@capture_number[i][0].to_i] then
						record[6] = record[6].sub(/\\(\d)/, @capture_string[@capture_number[i][0].to_i])										 #恢复regex
					end
				end
				if (record[5] =~ /#{record[6]}/) == nil	   #验证regex
					@wr_keywords += 1
					puts "#{index} >> kewords wrong: #{record[5]} => #{record[6]}"
				end
			rescue										   #捕获异常
				@wr_keywords+= 1
				puts "error: #{$!} at: #{$@}"
			end
		end
		#puts "end ==== Keywords ===="
	end

	#-------------------------------------------------------
	# Function: 验证description的regex
	# Input:	title的捕获文本，csv记录，csv记录编号	
	# Output:	NONE
	#-------------------------------------------------------
	def check_description(capture_string, record, index)
		if record[8] == "\\static" || record[8] == "\\null" then
		else
			begin
				record[8].strip!						#去除regex两端空格
				tmp_record8 = record[8]
				a = record[8].scan(/\\(\d)/)			#捕获regex中的\num，用以恢复regex
				@capture_number = Array.new(a)
				for i in 0..(@capture_number.length - 1)
					if @capture_string[@capture_number[i][0].to_i] then
						record[8] = record[8].sub(/\\(\d)/, @capture_string[@capture_number[i][0].to_i])
					end
				end
				if (record[7] =~ /#{record[8]}/) == nil #验证regex
					@wr_description += 1
					puts "#{index} >> discription wrong: #{record[7]} => #{record[8]}"
				end
			rescue										#捕获异常
				@wr_description += 1
				puts "error: #{$!} at: #{$@}"
			end
		end
	end

	#-------------------------------------------------------
	# Function:	验证正则表达式的核心函数
	# Input:	CSV记录，CSV记录编号
	# Output:	NONE
	#-------------------------------------------------------
    def check_core(record, index)						
        #puts record
		#url
		record[2].strip!
		if (record[1] =~ /#{record[2]}/) == nil			#验证url的regex 
			@wr_url += 1
			#puts "#{index} >> url wrong: #{record[1]} => #{record[2]}"
		end
		#title
		record[4].strip!
		if record[4] == "\\static" || record[4] == "\\null" then
		else
			if (record[3] =~ /#{record[4]}/) == nil		#验证title的regex 
				@wr_title += 1
				puts "#{index} >> title wrong: #{record[3]} => #{record[4]}"
			end
			@capture_string= $~.to_a					#存储捕获的分组信息
			check_keywords(@capture_string, record, index)		#验证关键字regex
			check_description(@capture_string, record, index)	#验证描述的regex
		end
    end

	#-------------------------------------------------------
	# Function:	报表输出 
	# Input:	NONE
	# Output:	NONE
	#-------------------------------------------------------
	#def statics(wr_url, wr_title, wr_keywords, wr_description)
	def statics()
		puts "========================================================================="
		print "Total Wrong URL: "
		puts @wr_url
		print "Total Wrong Title: "
		puts @wr_title 
		print "Total Wrong Keywords: "
		puts @wr_keywords 
		print "Total Wrong Description: "
		puts @wr_description 
		print "Time: "
		puts Time.now
	end
end

meta_file = "meta_utf8.csv"
host_regex = HostRegex.new
host_regex.check(meta_file)
