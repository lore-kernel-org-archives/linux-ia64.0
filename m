From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Thu, 25 Sep 2003 01:34:11 +0000
Subject: Unaligned access question
Message-Id: <marc-linux-ia64-106445366428887@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

This isn't directly related to kernel development, but I am a bit
stumped as to why my test program below causes an unaligned access
when 'i' is 7 (that is, when it tries to access across a 64 bit
boundary of 'array').  It's counter intuitive to me, I would have
expected it either fault on all loads (for every value of 'i') or to
have not faulted at all.

(yes, this is abstracted from some code that is chopping up data
coming over the network, which seems to be a common cause of alignment
problems).

Thanks for any suggestions,

-i
ianw@gelato.unsw.edu.au
http://www.gelato.unsw.edu.au

--- little test program ---

#include <stdio.h>
 
typedef struct a_struct_t {
        unsigned char a[2];
} a_struct;
 
void print(const a_struct st) {
        printf("%p -> %c | %p -> %c\n", &st.a[0], st.a[0], &st.a[1], st.a[1]);
}
 
int main(void)
{                   
        unsigned char *array = "1234567812345678";
                                
        int i;
 
        for ( i = 1 ; i < 10 ; i+=2 ) {
                printf("array[%d] %p\n", i, &array[i]);
                print( *((a_struct*)&array[i]) );
        }
        return 0;
}


--- sample output ---

array[1] 0x4000000000000a79
0x60000fffffffbcf0 -> 2 | 0x60000fffffffbcf1 -> 3
array[3] 0x4000000000000a7b
0x60000fffffffbcf0 -> 4 | 0x60000fffffffbcf1 -> 5
array[5] 0x4000000000000a7d
0x60000fffffffbcf0 -> 6 | 0x60000fffffffbcf1 -> 7
array[7] 0x4000000000000a7f
align(20189): unaligned access to 0x4000000000000a7f, ip=0x4000000000000770
0x60000fffffffbcf0 -> 8 | 0x60000fffffffbcf1 -> 1
array[9] 0x4000000000000a81
0x60000fffffffbcf0 -> 2 | 0x60000fffffffbcf1 -> 3

