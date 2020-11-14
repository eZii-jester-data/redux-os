# typed: false
  class EziiOsPath
    attr_accessor :global_path, :file_system # should stay for longer

    attr_accessor :dropbox_metainfo # should be refactored

    attr_accessor :https_url, :local_file_system_path, :complementary_local_file_system_paths # hacky

    def initialize(global_path)
      self.global_path = global_path
      self.file_system = FileSystem.find_by(machine_readable_identifier: file_system_identifier)
      self.complementary_local_file_system_paths = []
    end

    def file_system_path
      global_path.sub(/\A(?:\/)?#{self.file_system.machine_readable_identifier}/, '')
    end

    def file_system_identifier
      global_path.match(/\A[^\/]+/)[0]
    end

    def to_s
      return file_system_path
    end

    def hacky_split_path(*args)
      to_s.split(*args)
    end

    def split(*args)
      hacky_split_path(*args)
    end

    def inspect
      "#{self.class.name}#inspect:  #{global_path}"
    end

    def file?
      self.file_system.file?(self)
    end

    def modified_at
      self.file_system.path_modified_at(self)
    end

    # def https_url
    #   self.file_system.http_url(self)
    # end
  end
