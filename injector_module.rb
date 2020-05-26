module InjectorModule

	# We Need to Refactor it later
	def injector_args
        inject = @sqlmap_hash_args.map {|key, value| "#{key} #{value} "}.join

        if @sqlmap_args.empty?
            return inject
        end

        return inject << @sqlmap_args.join

	end

	def check_optional_args
        if @sqlmap_args.size >= 1
            if @sqlmap_hash_args.size >= 1
                @more_options_to_attack = injector_args
                STDERR.puts "Debug section with hash: #{@more_options_to_attack}"
                return
            end
            @more_options_to_attack = @sqlmap_args.join
            STDERR.puts "Debug section: #{@more_options_to_attack}"
        end
	end

end