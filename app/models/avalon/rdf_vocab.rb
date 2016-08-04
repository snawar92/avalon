# -*- encoding: utf-8 -*-
# This file generated automatically using vocab-fetch from http://purl.org/dc/dcmitype/
require 'rdf'
module Avalon
  module RDFVocab
    class Derivative < RDF::StrictVocabulary("http://avalonmediasystem.org/rdf/vocab/derivative#")
      property :locationURL,
        label: "LocationURL".freeze,
        "rdfs:isDefinedBy" => %(avalon:).freeze,
        type: "rdfs:Class".freeze
      property :hlsURL,
        label: "HlsURL".freeze,
        "rdfs:isDefinedBy" => %(avalon:).freeze,
        type: "rdfs:Class".freeze
      property :duration,
        "rdfs:isDefinedBy" => %(avalon:).freeze,
        type: "rdfs:Class".freeze
      property :trackID,
        "rdfs:isDefinedBy" => %(avalon:).freeze,
        type: "rdfs:Class".freeze
      property :hlsTrackID,
        "rdfs:isDefinedBy" => %(avalon:).freeze,
        type: "rdfs:Class".freeze
      property :isManaged,
        "rdfs:isDefinedBy" => %(avalon:).freeze,
        type: "rdfs:Class".freeze
      property :derivativeFile,
          "rdfs:isDefinedBy" => %(avalon:).freeze,
          type: "rdfs:Class".freeze
      property :quality,
          "rdfs:isDefinedBy" => %(avalon:).freeze,
          type: "rdfs:Class".freeze
      property :mime_type,
          "rdfs:isDefinedBy" => %(avalon:).freeze,
          type: "rdfs:Class".freeze
      property :audio_codec,
          "rdfs:isDefinedBy" => %(avalon:).freeze,
          type: "rdfs:Class".freeze
      property :audio_bitrate,
          "rdfs:isDefinedBy" => %(avalon:).freeze,
          type: "rdfs:Class".freeze
      property :video_codec,
          "rdfs:isDefinedBy" => %(avalon:).freeze,
          type: "rdfs:Class".freeze
      property :video_bitrate,
          "rdfs:isDefinedBy" => %(avalon:).freeze,
          type: "rdfs:Class".freeze
      property :resolution,
          "rdfs:isDefinedBy" => %(avalon:).freeze,
          type: "rdfs:Class".freeze
    end
  end
end
