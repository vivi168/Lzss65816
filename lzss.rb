class Lzss
    EI = 11
    EJ = 4
    N = (1 << EI)       # buffer size
    F = ((1 << EJ) + 1) # lookahead buffer size

    def initialize(source)
        @buffer = Array.new(N * 2)

        @infile = []
        @infile_ptr = 0

        File.open(source, 'r') do |f|
            f.each_byte do |byte|
                @infile << byte
            end
        end

        p @infile.size
    end

    def fgetc
        c = @infile[@infile_ptr]
        @infile_ptr += 1

        c
    end

    def getbit(n)
        x = 0
        buf = 0
        mask = 0

        n.times do |i|
            if mask == 0
                buf = fgetc

                return nil if (buf == nil)

                mask = 128
            end

            x <<= 1

            if (buf & mask) != 0
                x += 1
            end

            mask >>= 1
        end

        p x
        x
    end

    def decode
        c = 0
        while c = getbit(8) != nil
        end
    end
end




p Lzss.new('big.encoded').decode
