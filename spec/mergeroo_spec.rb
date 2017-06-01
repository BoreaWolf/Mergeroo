require 'mergeroo'

RSpec.describe Mergeroo, "#merge" do
	context "with no local includes" do
		test_file = "testaroo/testaroo.java"
		test_dir = File.dirname test_file
		before do
			unless Dir.exists? test_dir then
				Dir.mkdir test_dir
			end
		end
		after(:each) do
			FileUtils.rm_rf test_dir
		end

		it "removes the package line" do
			File.write( test_file, "package testaroo;\n\nclass Testaroo {\n}" )

			result = Mergeroo.new(:error).merge( test_file )
			expect( result ).to eq "\n\nclass Testaroo {\n}"

			File.delete test_file
		end

		it "keeps the external includes" do
			File.write( test_file, "package testaroo;\nimport java.io.*;\n\nclass Testaroo {\n}" )

			result = Mergeroo.new(:error).merge( test_file )
			expect( result ).to eq "\nimport java.io.*;\n\nclass Testaroo {\n}"

			File.delete test_file
		end
	end
end
