From: Barclay Jameson <almightybeeij@gmail.com>
Date: Tue, 20 Aug 2013 00:05:59 +0000
Subject: SGI Atix 4700 Help
Message-Id: <CAMzumdZ6Yf+tonQMxEa-vWueHJtkwpVZeO7HCx1xs3kAUkY3rw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I have posted on Nekochan
(http://forums.nekochan.net/viewtopic.php?f=3&t727918) asking help
for an error when trying to boot a Kernel compiled >= 3.2 (using
Debian Wheezy).
Here is the error:

000 051.21^1#0a: index time stamp         type      component    subcomponent
000 051.21^1#0a: ----- ------------------ --------- ------------ ------------
000 051.21^1#0a:     0 0x000000c92deef702 MD_HW     051.21^1#0
Non-existent Memory Address Error
000 051.21^1#0a:     1 0x000000ce43920f08 PI_HW     051.21^1#0   RRB
Time-out Error
000 051.21^1#0a:     2 0x000000ce43b16400 PROC_MCA  051.21^1#0a  Bus Check

A more detailed error is listed below:

000 051.21^1#0a:   SH2_EVENT_OCCURRED                      : 0x0000008180000003
000 051.21^1#0a:    MD Hardware Interrupt Pending
000 051.21^1#0a:   SH2_FIRST_ERROR                         : 0x0000000000000002
000 051.21^1#0a:    MD Hardware Interrupt Pending
000 051.21^1#0a:   SH2_MEM_ERROR_SUMMARY                   : 0x0000007800000002
000 051.21^1#0a:    Non-existent Memory Address Error
000 051.21^1#0a:   SH2_MEM_FIRST_ERROR                     : 0x0000000000000002
000 051.21^1#0a:    MD_HW_INT: Non-existent Memory Address Error
000 051.21^1#0a:   SH2_MISC_ERR_HDR_UPPER                  : 0x0000000001f00004
000 051.21^1#0a:     Non-Existant Memory Address Error Header Captured
000 051.21^1#0a:     Echo: 0x1f
000 051.21^1#0a:   SH2_MISC_ERR_HDR_LOWER                  : 0x8800010000000000
000 051.21^1#0a:     Source  : pi chiplet, nasid 0x0
000 051.21^1#0a:     Command : NCRD, Non-coherent read
000 051.21^1#0a:     Read Operation
000 051.21^1#0a:   SH2_MISC_ADRS_ERR_HDR_LOWER_A           : 0x80000001014cf070
000 051.21^1#0a:     Address <37:0>: 0x1014cf070
000 051.21^1#0a:     Read Operation
000 051.21^1#0a:   SH2_MD_HW_TIME_STAMP                    : 0x800000fa22fade06
000 051.21^1#0a:
000 051.21^1#0a: PI_HW :051.21^1#0 :RRB Time-out Error
000 051.21^1#0a:
000 051.21^1#0a:   SH2_EVENT_OCCURRED                      : 0x0000008180000003
000 051.21^1#0a:    PI Hardware Interrupt Pending
000 051.21^1#0a:   SH2_FIRST_ERROR                         : 0x0000000000000002
000 051.21^1#0a:   SH2_PI_ERROR_SUMMARY                    : 0x0000000000000010
000 051.21^1#0a:    RRB Time-out Error
000 051.21^1#0a:   SH2_PI_FIRST_ERROR                     : 0x0000000000000010
000 051.21^1#0a:    RRB Time-out Error
000 051.21^1#0a:   SH2_PI_ERROR_DETAIL_1                      :
0xfe200001014cf071
000 051.21^1#0a:   SH2_PI_ERROR_DETAIL_2                      :
0x000000001f0801f1
000 051.21^1#0a:     Address      : 0x1014cf070
000 051.21^1#0a:     Table Select : 0x4
000 051.21^1#0a:     Command      : RESERVED_FE
000 051.21^1#0a:     IsReal       : 0x1
000 051.21^1#0a:     RRB Idx      : 0x1f
000 051.21^1#0a:     WRB Idx      : 0x0
000 051.21^1#0a:     IRB Idx      : 0x0
000 051.21^1#0a:     Error Code   : 0x4
000 051.21^1#0a:     Echo         : 0x1f
000 051.21^1#0a:     Source       : not available
000 051.21^1#0a:     Supplemental : 0x0
000 051.21^1#0a:     AXB Queue    : 0x0
000 051.21^1#0a:   SH2_PI_HW_TIME_STAMP                    : 0x800000feba7afc05
000 051.21^1#0a:
000 051.21^1#0a: PROC_MCA :051.21^1#0a :Bus Check
000 051.21^1#0a:
000 051.21^1#0a:   processor lid                     : 0x0000000000000000
000 051.21^1#0a:     cpu: A nasid: 0x0
000 051.21^1#0a:   processor state parameter         : 0x20010000fff21120
000 051.21^1#0a:     rendevous was not attempted
000 051.21^1#0a:     min state is valid
000 051.21^1#0a:     not continuable
000 051.21^1#0a:     machine check is isolated
000 051.21^1#0a:     more info available
000 051.21^1#0a:     ip logged is not precise
000 051.21^1#0a:     min state is not precise
000 051.21^1#0a:     shared MCA
000 051.21^1#0a:     bus check
000 051.21^1#0a:     PAL recovery status:
000 051.21^1#0a:       error was isolated and contained, continuable
if sw can recover
000 051.21^1#0a:   processor error map               : 0x0000000001000000
000 051.21^1#0a:     processor code id: 0
000 051.21^1#0a:     logical thread id: 0
000 051.21^1#0a:     processor bus level 1 error
000 051.21^1#0a:   processor structure: bus
000 051.21^1#0a:     bus check                         : 0x1880000000800141
000 051.21^1#0a:       bus transaction size: 1
000 051.21^1#0a:       external bus error
000 051.21^1#0a:       transaction type: partial read
000 051.21^1#0a:       bus error severity: 0
000 051.21^1#0a:       bus hierarchy: 0
000 051.21^1#0a:       UCE detected on incoming
000 051.21^1#0a:       ia64 instruction set
000 051.21^1#0a:       machine check corrected
000 051.21^1#0a:       target address valid
000 051.21^1#0a:     target identifier                 : 0x00000001014cf071

Anybody have any any pointers to help me solve this problem?
