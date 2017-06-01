require 'mergeroo'

RSpec.describe Mergeroo, "#merge" do
  context "with no local includes" do
    test_file = "testaroo/testaroo.java"
    test_dir = File.dirname test_file
    before do
      if Dir.exists? test_dir then
        FileUtils.rm_rf test_dir
      end
      Dir.mkdir test_dir
    end
    after(:each) do
      FileUtils.rm_rf test_dir
    end

    it "removes the package line" do
      File.write( test_file, "package testaroo;\n\nclass Testaroo {\n}" )

      result = Mergeroo.new(:error).merge( test_file )
      expect( result ).to eq "\n\nclass Testaroo {\n}"
    end

    it "keeps the external includes" do
      File.write( test_file, "package testaroo;\nimport java.io.*;\n\nclass Testaroo {\n}" )

      result = Mergeroo.new(:error).merge( test_file )
      expect( result ).to eq "\nimport java.io.*;\n\nclass Testaroo {\n}"
    end

    it "preserves the class' publicness" do
      File.write( test_file, "package testaroo;\n\npublic class Testaroo {\n}" )

      result = Mergeroo.new(:error).merge( test_file )
      expect( result ).to eq "\n\npublic class Testaroo {\n}"
    end
  end

  context "with same-package includes" do
    test_file = "testaroo/testaroo.java"
    test_dir = File.dirname test_file
    before do
      if Dir.exists? test_dir then
        FileUtils.rm_rf test_dir
      end
      Dir.mkdir test_dir
    end
    after(:each) do
      FileUtils.rm_rf test_dir
    end

    it "merges simple files" do
      test_include = "#{test_dir}/includaroo.java"
      File.write( test_file, "package testaroo;\n\nclass Testaroo {\n}" )
      File.write( test_include, "package testaroo;\n\nclass Includaroo {\n}" )

      result = Mergeroo.new(:error).merge( test_file )
      expect( result ).to eq "\n\nclass Testaroo {\n}\n\nclass Includaroo {\n}"
    end

    ["class", "interface", "enum", "abstract class"].each do |object|
      it "removes the publicness of included #{object}s" do
        test_include = "#{test_dir}/includaroo.java"
        File.write( test_file, "package testaroo;\n\npublic #{object} Testaroo {\n}" )
        File.write( test_include, "package testaroo;\n\npublic #{object} Includaroo {\n}" )

        result = Mergeroo.new(:error).merge( test_file )
        expect( result ).to eq "\n\npublic #{object} Testaroo {\n}\n\n#{object} Includaroo {\n}"
      end
    end
  end
end
