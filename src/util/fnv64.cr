@[Link(ldflags: "#{__DIR__}/bindings/fnv64.o")]
lib LibFnv64
    fun fnv64(string : UInt8*) : UInt64
end

class Fnv64
    def self.hash(string : String) : UInt64
        result : UInt64 = LibFnv64.fnv64(string.to_unsafe)
        result &= 0x7FFFFFFFFFFFFFFF
        return result
    end
end