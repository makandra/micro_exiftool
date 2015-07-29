# encoding: UTF-8

require 'spec_helper'
require 'tempfile'

describe MicroExiftool::File do

  let(:sample_file_path) { File.join(File.dirname(__FILE__), 'assets', 'image.jpg') }

  subject { described_class.new(sample_file_path) }

  describe '.new' do

    it 'complains about missing files' do
      proc {
        described_class.new('does/not/exist')
      }.should raise_error(MicroExiftool::NoSuchFile)
    end

  end


  describe '#attributes' do

    it 'returns prefixed file attributes as a hash' do
      subject.attributes.should include(
        'IPTC:ObjectName' => 'The IPTC Title',
        'IPTC:CopyrightNotice' => 'The IPTC Copyright',
        'EXIF:Copyright' => 'The EXIF Copyright'
      )
    end

  end


  describe '#[]' do

    it 'returns single attributes' do
      subject['IPTC:ObjectName'].should == 'The IPTC Title'
    end

  end

  describe 'update!' do

    let(:sample_file_copy) { Tempfile.new(['sample_file_copy', '.jpg']) }
    let(:sample_file_copy_path) { sample_file_copy.path }

    before do
      sample_file_copy.write(File.read(sample_file_path))
      sample_file_copy.close
    end

    subject { described_class.new(sample_file_copy_path) }
    let(:duplicate_subject) { described_class.new(sample_file_copy_path) }


    it 'modifies the given attributes in the file' do
      subject.update!(
        'IPTC:CopyrightNotice' => 'The new IPTC Copyright',
        'EXIF:Copyright' => 'The new EXIF Copyright',
      )

      duplicate_subject.attributes.should include(
        'IPTC:CopyrightNotice' => 'The new IPTC Copyright',
        'EXIF:Copyright' => 'The new EXIF Copyright',
      )
    end

    it 'does not touch other metadata' do
      attributes_before = subject.attributes

      subject.update!(
        'EXIF:Copyright' => 'The new EXIF Copyright',
      )

      attributes_after = duplicate_subject.attributes
      %w[EXIF:Copyright File:FileAccessDate File:FileInodeChangeDate].each do |key|
        attributes_before.delete(key)
        attributes_after.delete(key)
      end
      attributes_after.should == attributes_before
    end

    it 'modifies the given attributes on the current instance' do
      attributes_before = subject.attributes

      subject.update!(
        'EXIF:Copyright' => 'The new EXIF Copyright',
      )

      attributes_before['EXIF:Copyright'].should eq 'The EXIF Copyright'
      subject.attributes['EXIF:Copyright'].should eq 'The new EXIF Copyright'
    end

    it 'modifies files in place' do
      subject.update!(
        'EXIF:Copyright' => 'The new EXIF Copyright',
      )

      File.exist?(sample_file_copy_path + '_original').should eq false
    end

    it 'can assign characters that might need escaping' do
      new_copyright = %{'"& ;\/{}<>}
      subject.update!(
        'EXIF:Copyright' => new_copyright,
        'IPTC:CopyrightNotice' => new_copyright,
      )

      duplicate_subject['EXIF:Copyright'].should eq new_copyright
      duplicate_subject['IPTC:CopyrightNotice'].should eq new_copyright
    end

    it 'can assign non-ASCII characters' do
      new_copyright = '版权所有'
      subject.update!(
        'EXIF:Copyright' => new_copyright,
        'IPTC:CopyrightNotice' => new_copyright,
      )

      duplicate_subject['EXIF:Copyright'].should eq new_copyright
      duplicate_subject['IPTC:CopyrightNotice'].should eq new_copyright
    end

    it 'complains about exiftool errors' do
      Open3.stub(:capture3).and_return(['', 'some error', double('status', exitstatus: 1)])

      proc {
        subject.update!(
          'EXIF:Copyright' => 'The new EXIF Copyright',
        )
      }.should raise_error(MicroExiftool::ExifToolError, "Error running exiftool:\nsome error")
    end

    it 'will give a useful error if exiftool is not installed' do
      Open3.stub(:capture3).and_raise(Errno::ENOENT)

      proc {
        subject.update!(
          'EXIF:Copyright' => 'The new EXIF Copyright',
        )
      }.should raise_error(MicroExiftool::ExifToolError, 'Exiftool not installed')
    end

  end

end
