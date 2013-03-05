class Derivative < ActiveFedora::Base
  include ActiveFedora::Associations

  class_attribute :url_handler

  belongs_to :masterfile, :class_name=>'MasterFile', :property=>:is_derivation_of

  # These fields do not fit neatly into the Dublin Core so until a long
  # term solution is found they are stored in a simple datastream in a
  # relatively flat structure.
  #
  # The only meaningful value at the moment is the url, which points to
  # the stream location. The other two are just stored until a migration
  # strategy is required.
  has_metadata name: "descMetadata", :type => ActiveFedora::SimpleDatastream do |d|
    d.field :location_url, :string
    d.field :hls_url, :string
    d.field :duration, :string
    d.field :track_id, :string
  end

  delegate_to 'descMetadata', [:location_url, :hls_url, :duration, :track_id], unique: true

  has_metadata name: 'encoding', type: EncodingProfileDocument

  # Getting the track ID from the fragment is not great but it does reduce the number
  # of calls to Matterhorn 
  def self.create_from_master_file(masterfile, markup)
    # Looks for an existing derivative of the same quality
    # and adds the track URL to it
    quality = markup.tags.quality.first.split('-')[1] unless markup.tags.quality.empty?
    derivative = nil
    masterfile = MasterFile.find(masterfile.pid)
    masterfile.derivatives.each do |d|
      derivative = d if d.encoding.quality.first == quality
    end 

    # If same quality derivative doesn't exist, create one
    if derivative.blank?
      puts "CREATING"
      derivative = Derivative.create 
      derivative.track_id = markup.track_id
      
      derivative.duration = markup.duration.first
      derivative.encoding.mime_type = markup.mimetype.first
      derivative.encoding.quality = quality 

      derivative.encoding.audio.audio_bitrate = markup.audio.a_bitrate.first
      derivative.encoding.audio.audio_codec = markup.audio.a_codec.first
 
      unless markup.video.empty?
        derivative.encoding.video.video_bitrate = markup.video.v_bitrate.first
        derivative.encoding.video.video_codec = markup.video.v_codec.first
        derivative.encoding.video.resolution = markup.video.resolution.first
      end
    end

    if markup.tags.tag.include? "hls"   
      derivative.hls_url = markup.url.first
    else
      derivative.location_url = markup.url.first
    end

    derivative.masterfile = masterfile
    derivative.save
    
    derivative
  end

  def url_hash
    h = Digest::MD5.new
    h << location_url
    h.hexdigest
  end

  def tokenized_url(token, mobile=false)
    #uri = URI.parse(url.first)
    uri = streaming_url(mobile)
    "#{uri.to_s}?token=#{masterfile.mediapackage_id}-#{token}".html_safe
  end      

  def streaming_url(is_mobile=false)
    # We need to tweak the RTMP stream to reflect the right format for AMS.
    # That means extracting the extension from the end and placing it just
    # after the application in the URL

    protocol = is_mobile ? 'http' : 'rtmp'

    # Example input: /avalon/mp4:98285a5b-603a-4a14-acc0-20e37a3514bb/b3d5663d-53f1-4f7d-b7be-b52fd5ca50a3/MVI_0057.mp4
    regex = %r{^
      /(.+)             # application (avalon)
      /(?:(.+):)?       # prefix      (mp4:)
      ([0-9a-f-]{36})   # media_id    (98285a5b-603a-4a14-acc0-20e37a3514bb)
      /([0-9a-f-]{36})  # stream_id   (b3d5663d-53f1-4f7d-b7be-b52fd5ca50a3)
      /(.+?)            # filename    (MVI_0057)
      (?:\.(.+))?$      # extension   (mp4)
    }x

    uri = URI.parse(location_url)
    (application, prefix, media_id, stream_id, filename, extension) = uri.path.scan(regex).flatten
    if extension.nil? or prefix.nil?
      prefix = extension = [extension,prefix].find { |thing| not thing.nil? }
    end

    template = ERB.new(self.class.url_handler.patterns[protocol][format])
    result = File.join(Avalon::Configuration['streaming']["#{protocol}_base"],template.result(binding))
  end

  def format
    case
      when (not encoding.video.empty?)
        "video"
      when (not encoding.audio.empty?)
        "audio"
      else
        "other"
      end
  end
end 
