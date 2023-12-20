@[Link(ldflags: "#{__DIR__}/C-functions/fnv64.o")]
lib LibFnv64
    fun fnv64(string : Pointer(UInt8)) : UInt64
end

class Fnv64
    @@truncate : Bool = false
    def initialize(@@truncate : Bool)
    end

    def initialize
    end

    def hash(string : String) : UInt64
        result : UInt64 = LibFnv64.fnv64(string.to_unsafe)
        result &= 0x7FFFFFFFFFFFFFFF if @@truncate
        return result
    end
end