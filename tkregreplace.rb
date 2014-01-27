# This is a simple ruby script which uses the tk widget set for it's GUI
# environment.  The program currently accepts no arguments.
#
# The purpose of this program are as follows: 
# * to function as a tool for crafting regular expressions by showing a visual
#   representation of the match.
# * to be able to perform replacement operations on the matched text using all
#   the power that ruby regular expressions can provide, including the ability 
#   to use \1 \2 in the replacement string referring to groups captured by 
#   capturing parentheses.  
# * to function as a light weight text editor.  This last goal has sortof come
#   about as a bi-product of the implementation.

require 'tk'
require 'tkextlib/tile'

#puts Tk::Tile::Style.theme_names
#Tk::Tile::Style.theme_use "clam"
#Tk::Tile::Style.theme_use "alt"
#Tk::Tile::Style.theme_use "default"
#Tk::Tile::Style.theme_use "classic"

# This Class represents the TkRegReplace Program.  Instantiating an object of
# this class will effectively start the GUI.  You should not instantiate more
# than one instance of this class as once the TK environment is destroyed by
# the first instantiated object, it cannot be recreated again.
class TkRegReplace
    private
    # This method constructs a new instance of the TkRegReplace object
    # in effect starting the GUI.  It takes no parameters.  The return value
    # should not be used because by the time this function returns, the program
    # should have ended and the object will be in an invalid state
    def initialize
        @root = TkRoot.new

        @text = TkText.new(@root) do
            font '-Adobe-Courier-Medium-R-Normal--*-120-*-*-*-*-*-*'
        end

        @text.wrap = 'none'

        menu_spec = 
        [
            [
                ['File', 0],
                ['Open', proc {open_file}, 0, 'Ctrl+O'],
                '---',
                ['Quit', proc{exit}, 0, 'Ctrl+Q']
            ],
            [
                ['Edit', 0],
                ['Cut', proc{puts('Cut clicked')}, 2, 'Ctrl+X'],
                ['Copy', proc{puts('Copy clicked')}, 0, 'Ctrl+C'],
                ['Paste', proc{puts('Paste clicked')}, 0, 'Ctrl+V']
            ], 
            [
                ['Help', 0, {:menu_name=>'help'}],
                ['About This', proc{puts('xregexsearch&replace ruby script')}, 6]
            ]
        ]

        @mbar = Tk.root.add_menubar(menu_spec)
        @root.bind('Control-o', proc {open_file})
        @root.bind('Control-q', proc {exit})
        
        @frame1 = TkFrame.new(@root)
        @frame2 = TkFrame.new(@root)
        @frame3 = TkFrame.new(@root)

        @entry1 = TkEntry.new(@frame2)
        @entry1.bind('Return', proc {match})
        @entry2 = TkEntry.new(@frame2)

        @dmn = TkVariable.new(0)
        @checkbox1 = TkCheckButton.new(@frame3,
            'text' => "Dot matches newline mode",
            'variable' => @dmn
        )

        @ic = TkVariable.new(1)
        @checkbox2 = TkCheckButton.new(@frame3,
            'text' => "Ignore Case",
            'variable' => @ic
        )
        
        @tags = TkTextTag.new(@text, 'background' => 'red')
        @tag = TkTextTag.new(@text, 'background' => 'blue')

        @button1 = TkButton.new(@frame1, 
            'text' => 'Match', 
            'command' => proc {@text.focus; match}
        )

        @button2 = TkButton.new(@frame1, 
            'text' => 'Match again', 
            'command' => proc {@text.focus; match_again}
        )
        
        @button3 = TkButton.new(@frame1,
            'text' => "Match again reverse",
            'command' => proc {@text.focus; match_again_backwards}
        )


        @button4 = TkButton.new(@frame1,
            'text' => "Replace",
            'command' => proc {replace}
        )

        @button5 = TkButton.new(@frame1,
            'text' => "Replace All (from here downward)",
            'command' => proc {replace_all}
        )

        @label1 = TkLabel.new(@frame2,
            'text' => "Search String"
        )

        @label2 = TkLabel.new(@frame2,
            'text' => "Replace String"
        )


        @scrollBar = TkScrollbar.new(@root, 
            'command' => proc {|*args| @text.yview(*args)}
        )

        @scrollBar2 = TkScrollbar.new(@root, 
            'orient' => "horizontal", 
            'command' => proc {|*args| @text.xview(*args)}
        )

        @text.yscrollcommand(proc { |first, last| @scrollBar.set(first, last)})
        @text.xscrollcommand(proc { |first, last| @scrollBar2.set(first, last)})

        @frame1.pack('side' => 'bottom', 'fill' => 'x') 
        @frame2.pack('side' => 'bottom', 'fill' => 'x', 'pady' => 10)
        @frame3.pack('side' => 'bottom', 'fill' => 'x')
        @checkbox1.pack('side' => 'left', 'fill' => 'x')
        @checkbox2.pack('side' => 'left', 'fill' => 'x')
        @label1.pack('side' => 'left', 'fill' => 'x')
        @entry1.pack('side' => 'left', 'fill' => 'x', 'expand' => true)
        @label2.pack('side' => 'left', 'fill' => 'x')
        @entry2.pack('side' => 'left', 'fill' => 'x', 'expand' => true)
        @button1.pack('side' => 'left', 'fill' => 'x', 'expand' => true)
        @button2.pack('side' => 'left', 'fill' => 'x', 'expand' => true)
        @button3.pack('side' => 'left', 'fill' => 'x', 'expand' => true)
        @button4.pack('side' => 'left', 'fill' => 'x', 'expand' => true)
        @button5.pack('side' => 'left', 'fill' => 'x', 'expand' => true)
        @scrollBar.pack('side' => 'right', 'fill' => 'y') 
        @scrollBar2.pack('side' => 'bottom', 'fill' => 'x') 
        @text.pack('side' => 'right', 'fill' => 'both', 'expand' => true)

        Tk.mainloop
    end

    # This is the callback that is associated with the file_open menu item
    #  Parameters: none
    #  Return Value: none
    def open_file   # :doc:
        filetypes = [["All Files", "*"], ["Text Files", "*.txt"]]
        filename = Tk.getOpenFile('filetypes' => filetypes, 'parent' => @root)
        if filename != ""
            @text.value=(File.read(filename))
        end
    end
   
    # This is the callback that performs the match operation, if dot matches
    # newline mode is selected then this method will perform it's operation in a
    # while loop which can be expensive.  Even disregarding the while loop for
    # normal matches, this method is pretty expensive.  It has to do with how
    # I'm calculating the mapping between the TK coordinates which are needed by
    # the TkTags and the very large string that is returned from the 
    # TkText#value call.  This could stand improvement, but since it's
    # functioning I'm probably only going to come back to it after most of the
    # rest of the functionality of the program is in place.
    #  Parameters: none
    #  Return Value: none 
    def match   # :doc:
        y = 1; x = 0
        map = Array.new
        string = @text.value
        for i in 0..string.length
            if (string[i] == "\n"[0])
                map[i] = "#{y}.#{x}"
                y = y+1
                x = 0
            else
                map[i] = "#{y}.#{x}"
                x = x+1
            end
        end
        
        @tags.destroy
        @tag.destroy
        @tags = TkTextTag.new(@text, 'background' => 'red')
        @tag = TkTextTag.new(@text, 'background' => 'blue')
        
        if @entry1.value != ""
            begin
                if @dmn == 1 and @ic == 1
                    @reg = Regexp.new("(?im:#{@entry1.value})")
                elsif @ic == 1
                    @reg = Regexp.new("(?i:#{@entry1.value})")
                elsif @dmn == 1
                    @reg = Regexp.new("(?m:#{@entry1.value})")
                else
                    @reg = Regexp.new("#{@entry1.value}")
                end
            rescue RegexpError => e
                TkWarning.new("The regular expression you entered is invalid, try again")
                return
            end
            if (@reg =~ string and $& != "")
                c = 0
                @tag_index = 0
                @tags.add("#{map[$`.size]}", "#{map[($`.size + $&.size)]}")
                @tag.add(@tags.ranges[0][0],@tags.ranges[0][1])
                @tags.remove(@tag.ranges[0][0], @tag.ranges[0][1])
                @text.set_insert("#{map[$`.size]}")
                @text.see("#{map[$`.size]}")
                c = c + $&.size + $`.size
                while (@reg =~ $')
                    if $& == ""
                        $' =~ /\n/ 
                        c = c + 1
                    else
                        @tags.add("#{map[c + $`.size]}", "#{map[c + $`.size + $&.size]}")
                        c = c + $&.size + $`.size
                    end
                end
            end
        end
    end
    
    # This callback matches the next item in the original match, it does not 
    # check if the user re-entered a new search string, it simply moves to
    # the next tag.  It wraps if you are on the last tag
    #  Parameters: none
    #  Return Value: none
    def match_again   # :doc:
        if @tags.ranges.length > 0
            @tag_index = @tag_index + 1
            @tag_index = 0 if @tag_index > @tags.ranges.length
            @tags.add(@tag.ranges[0][0], @tag.ranges[0][1])
            @tag.remove(@tag.ranges[0][0], @tag.ranges[0][1])
            @tag.add(@tags.ranges[@tag_index][0], @tags.ranges[@tag_index][1])
            @tags.remove(@tag.ranges[0][0], @tag.ranges[0][1])
            @text.set_insert(@tag.ranges[0][0])
            @text.see(@tag.ranges[0][0])
        end
    end
        
    # This callback matches the previous item in the original match, it does not
    # check if the user re-entered a new search string, it simply moves to the
    # previous tag.  It wraps if you are on the first tag
    #  Parameters: none
    #  Return Value: none
    def match_again_backwards   # :doc:
        if @tags.ranges.length > 0
            @tag_index = @tag_index - 1
            @tag_index = @tags.ranges.length if @tag_index < 0
            @tags.add(@tag.ranges[0][0], @tag.ranges[0][1])
            @tag.remove(@tag.ranges[0][0], @tag.ranges[0][1])
            @tag.add(@tags.ranges[@tag_index][0], @tags.ranges[@tag_index][1])
            @tags.remove(@tag.ranges[0][0], @tag.ranges[0][1])
            @text.set_insert(@tag.ranges[0][0])
            @text.see(@tag.ranges[0][0])
        end
    end

    # This callback is responsible for performing replacements.  It will only
    # carry out replacements in already highlighted areas, ie if you have typed
    # some text into the text box, and it has text that would have been matched
    # by the match command, but you haven't re-executed the match callback
    # function, that text will not be a part of the replacement.
    #  Parameters: none
    #  Return Value: none
    def replace   # :doc:
        if @entry1.value != ""
            if @dmn == 1 and @ic == 1
                @reg = Regexp.new("(?im:#{@entry1.value})")
            elsif @ic == 1
                @reg = Regexp.new("(?i:#{@entry1.value})")
            elsif @dmn == 1
                @reg = Regexp.new("(?m:#{@entry1.value})")
            else
                @reg = Regexp.new("#{@entry1.value}")
            end
        end
        
        if (@tag.ranges.length > 0)
            string = @text.get(@tag.ranges[0][0], @tag.ranges[0][1])
            string.sub!(@reg, @entry2.value)
            @text.insert(@tag.ranges[0][0], string)
            @text.delete(@tag.ranges[0][0], @tag.ranges[0][1])
            unless @tag_index > @tags.ranges.length-1
                @tag.add(@tags.ranges[@tag_index][0], @tags.ranges[@tag_index][1])
                @tags.remove(@tag.ranges[0][0], @tag.ranges[0][1])
                @text.set_insert(@tag.ranges[0][0])
                @text.see(@tag.ranges[0][0])
            end
        end
    end

    # This callback is responsible for performing replacements.  It will only
    # carry out replacements in already highlighted areas, ie if you have typed
    # some text into the text box, and it has text that would have been matched
    # by the match command, but you haven't re-executed the match callback
    # function, that text will not be a part of the replacement.  This method
    # replaces all occurances in one go.
    #  Parameters: none
    #  Return Value: none
    def replace_all   # :doc:
        if @entry1.value != ""
            if @dmn == 1 and @ic == 1
                @reg = Regexp.new("(?im:#{@entry1.value})")
            elsif @ic == 1
                @reg = Regexp.new("(?i:#{@entry1.value})")
            elsif @dmn == 1
                @reg = Regexp.new("(?m:#{@entry1.value})")
            else
                @reg = Regexp.new("#{@entry1.value}")
            end
        end

        while(@tag.ranges.length > 0)
            string = @text.get(@tag.ranges[0][0], @tag.ranges[0][1])
            string.sub!(@reg, @entry2.value)
            @text.insert(@tag.ranges[0][0], string)
            @text.delete(@tag.ranges[0][0], @tag.ranges[0][1])
            unless @tag_index > @tags.ranges.length-1
                @tag.add(@tags.ranges[@tag_index][0], @tags.ranges[@tag_index][1])
                @tags.remove(@tag.ranges[0][0], @tag.ranges[0][1])
                @text.set_insert(@tag.ranges[0][0])
                @text.see(@tag.ranges[0][0])
            end
        end
    end
end

TkRegReplace.new

#      mark = TkTextMarkInsert.new(@text)
#      puts @text.index(mark)

