require 'mergeroo'

RSpec.describe Mergeroo, "#merge" do
	context "with no local includes" do
		it "removes the package line" do
			test_file = "testaroo.java"
			out_file = "testaroo.mergeroo.java"

			File.write( test_file, "package testaroo;\n\nclass Testaroo {\n}" )
			Mergeroo.new.merge( test_file )
			result = File.read( out_file )
			expect(result).to eq "\n\nclass Testaroo {\n}"

			File.delete( test_file )
			File.delete( out_file )
		end

		it "keeps the external includes" do
			test_file = "testaroo.java"
			out_file = "testaroo.mergeroo.java"

			File.write( test_file, "import java.io.*;\n\nclass Testaroo {\n}" )
			Mergeroo.new.merge( test_file )
			result = File.read( out_file )
			expect(result).to eq "import java.io.*\n\nclass Testaroo {\n}"

			File.delete( test_file )
			File.delete( out_file )
		end
	end
end
