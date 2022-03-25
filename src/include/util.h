/*
 *  Copyright (C) 2022 RapidSilicon
 *
 */

#ifndef UTIL_H
#define UTIL_H

#ifdef ENABLE_ENCRYPT
    #define KEY 0x55
    
    template<int... I>
    struct Indexes { using type = Indexes<I..., sizeof...(I)>; };
    
    template<int N>
    struct Make_Indexes { using type = typename Make_Indexes<N-1>::type::type; };
    
    template<>
    struct Make_Indexes<0> { using type = Indexes<>; };
    
    template<typename Indexes>
    struct MetaString;
    
    
    template<int... I>
    struct MetaString<Indexes<I...>>
    {
        constexpr MetaString(const char* str)
        	: buffer_ {encrypt(str[I])...} { }
        
        inline const char* decrypt()
        {
        	for(size_t i = 0; i < sizeof...(I); ++i)
        		buffer_[i] = decrypt(buffer_[i]);
        	buffer_[sizeof...(I)] = 0;
        	return buffer_;
        }
        
        private:
        constexpr char encrypt(char c) const { return c ^ KEY; }
        constexpr char decrypt(char c) const { return encrypt(c); }
        
        private:
        char buffer_[sizeof...(I) + 1];
    };
    
    #define OBFUSCATED(str) (MetaString<Make_Indexes<sizeof(str)-1>::type>(str))
    #define DEOBFUSCATED(str) std::string(str.decrypt())
#else
    #define OBFUSCATED(str) str
    #define DEOBFUSCATED(str) std::string(str)
#endif

#endif // UTIL_H
