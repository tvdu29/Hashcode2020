#!/usr/bin/env ruby

filename = ARGV[0]
file = File.open(ARGV[0], 'r')

puts filename

meta_data_num = Array.new

@meta_data = file.readline.split(' ')
x = 0
@meta_data.each do |elem|
  meta_data_num[x] = elem.to_i
  x += 1
end

books_wgt = Array.new

@books_wgt_meta = file.readline.split(' ')
x = 0
@books_wgt_meta.each do |elem|
  books_wgt[x] = elem.to_i
  x += 1
end

libs = Array.new
x = 0
@lib_data = file.readline.split(' ')
while !file.eof?
  libs[x] = Array.new
  y = 0
  @lib_data.each do |elem|
    libs[x][y] = elem.to_i
    y += 1
  end
  libs[x][y] = Array.new
  @books = file.readline.split(' ')
  z = 0
  @books.each do |elem|
    libs[x][y][z] = elem.to_i
    z += 1
  end
  libs[x][y] = libs[x][y].uniq.sort_by { |b| books_wgt[b]}.reverse
  x += 1
  if !file.eof?
    @lib_data = file.readline.split(' ')
  end
end

index_max_l = libs.length - 1

wgt_libs = Array.new

x = 0
libs.each do |lib|
  lib[3] = lib[3].sort_by { |b| books_wgt[b]}.reverse
  nb_scan_max = (meta_data_num[2] - lib[1]) * lib[2]
  nb_scanned = nb_scan_max < lib[3].length ? nb_scan_max : lib[3].length
  score = 0
  y = 0
  while y < nb_scanned
    score += books_wgt[lib[3][y]]
    y += 1
  end
  wgt_libs[x] = score
  x += 1
end

final_score = 0
final_libs = Array.new
x = 0
sum_times = 0
while x <= libs.length
  min_wgt = wgt_libs.max {|a, b| a <=> b}
  break if min_wgt <= 0

  min_index = wgt_libs.index(min_wgt)
  if !final_libs.include? min_index
    final_libs.push(min_index)
    sum_times += libs[min_index][1]
    final_score += wgt_libs[min_index]
    wgt_libs[min_index] = -1
  end
  libs[min_index][3].each do |book|
    books_wgt[book] = 0
  end
  ((0..index_max_l).to_a - final_libs).each do |lib_index|
    libs[lib_index][3] = libs[lib_index][3] - libs[min_index][3]
    libs[lib_index][3] = libs[lib_index][3].sort_by { |b| books_wgt[b]}.reverse
    nb_scan_max = (meta_data_num[2] - sum_times - libs[lib_index][1]) * libs[lib_index][2]
    nb_scan_max = nb_scan_max.negative? ? 0 : nb_scan_max
    nb_scanned = nb_scan_max < libs[lib_index][3].length ? nb_scan_max : libs[lib_index][3].length
    wgt_libs[lib_index] = 0
    libs[lib_index][3].take(nb_scanned).each { |b| wgt_libs[lib_index] += books_wgt[b]}
  end
  x += 1
end


puts "final libs: " + final_libs.inspect
puts "final score: " + final_score.to_s

fileout = File.open(filename.to_s.split('/')[1].split('.txt')[0] + ".out", "w+")
fileout.write(wgt_libs.length.to_s + "\n")

final_libs.each_with_index do |lib, index|
  fileout.write(index.to_s + " " + libs[index][3].length.to_s + "\n")
  libs[index][3].each do |book|
    fileout.write(book.to_s + " ")
  end
  fileout.write("\n")
end
