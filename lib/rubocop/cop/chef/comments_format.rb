#
# Copyright 2016, Tim Smith
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module RuboCop
  module Cop
    module Chef
      # Checks for incorrectly formatted headers
      #
      # @example
      #
      #   # bad
      #   Copyright 2013-2016 Chef Software, Inc.
      #   Recipe default.rb
      #   Attributes default.rb
      #   License Apache2
      #   Cookbook tomcat
      #   Cookbook Name:: Tomcat
      #   Attributes File:: default
      #
      #   # good
      #   Copyright:: 2013-2016 Chef Software, Inc.
      #   Recipe:: default.rb
      #   Attributes:: default.rb
      #   License:: Apache License, Version 2.0
      #   Cookbook Name:: Tomcat
      #
      class CommentFormat < Cop
        MSG = 'Properly format header comments'.freeze

        def investigate(processed_source)
          return unless processed_source.ast
          processed_source.comments.each do |comment|
            next unless comment.inline? # headers aren't in blocks

            if invalid_comment?(comment)
              add_offense(comment, comment.loc.expression, MSG)
            end
          end
        end

        private

        def autocorrect(comment)
          # Extract the type and the actual value. Strip out "Name" or "File"
          # 'Cookbook Name' should be 'Cookbook'. Also skip a :: if present
          match = /^# ?([A-Za-z]+)\s?(?:Name|File)?(?:::)?\s(.*)/.match(comment.text)
          comment_type, value = match.captures
          correct_comment = "# #{comment_type}:: #{value}"

          ->(corrector) { corrector.replace(comment.loc.expression, correct_comment) }
        end

        def invalid_comment?(comment)
          comment_types = %w(Author Cookbook Library Attribute Copyright Recipe Resource Definition License)
          comment_types.any? do |comment_type|
            /^#\s*#{comment_type}\s+/.match(comment.text)
          end
        end
      end
    end
  end
end
