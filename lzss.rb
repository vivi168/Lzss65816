class Lzss
    EI = 11
    EJ = 4
    N = (1 << EI)       # buffer size
    F = ((1 << EJ) + 1) # lookahead buffer size

    def initialize(source, dest)
        @dest = dest
        @buffer = Array.new(N * 2)

        @infile = []
        @infile_ptr = 0

        @outfile = []

        @buf = 0
        @mask = 0

        File.open(source, 'r') do |f|
            f.each_byte do |byte|
                @infile << byte
            end
        end
    end

    def decode
        r = N - F
        c = 0

        r.times do |i|
            @buffer[i] = 32
        end

        while c != nil
            c = getbit(1)
            if c == 1
                byte = getbit(8)

                break if (byte == nil)

                @outfile << byte
                @buffer[r] = byte
                r = (r + 1) & (N - 1)

            else
                i = getbit(EI)
                j = getbit(EJ)

                break if (i == nil || j == nil)

                0.upto(j+1) do |k|
                    c = @buffer[(i + k) & (N - 1)]

                    @outfile << c
                    @buffer[r] = c
                    r = (r + 1) & (N - 1)
                end
            end
        end

        @outfile
    end

    def write
        File.open(@dest, 'w+b') do |file|
            file.write([@outfile.map { |i| hex(i) }.join].pack('H*'))
        end
    end

    private

    def fgetc
        c = @infile[@infile_ptr]
        @infile_ptr += 1

        c
    end

    def getbit(n)
        x = 0

        n.times do |i|
            if @mask == 0
                @buf = fgetc

                return nil if (@buf == nil)

                @mask = 128
            end

            x <<= 1

            if (@buf & @mask) != 0
                x += 1
            end

            @mask >>= 1
        end

        x
    end

    def hex(num, rjust_len = 2)
        (num || 0).to_s(16).rjust(rjust_len, '0').upcase
    end
end

l = Lzss.new('big.png.lzss', 'big2.png')
l.decode
l.write
