From: Steve Ellcey <sje@cup.hp.com>
Date: Wed, 01 Aug 2001 22:02:40 +0000
Subject: [Linux-ia64] Re: optimization/3783
Message-Id: <marc-linux-ia64-105590693005982@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

FYI:  I have spent a little time looking at this bug, I haven't got a
fix but I did create a smaller test program that I am including in this
mail.  Running it on HP-UX IA64 it looks like the optimizer is going
into an infinite loop in canon_rtx because one of the entries (REG 351
in my case) is set to be a plus RTX of REG 351 and CONST 1.  How that
self-referential access got in there, I don't know but it seems to be
the cause of the problem.  Anyway I thought I would just send off what
I know and the smaller test case before going off on some vacation.

Steve Ellcey
sje@cup.hp.com

extern struct buffer_headX *udf_read_taggedX(unsigned short *);
#pragma pack(1)
typedef struct {
        unsigned int extLength;
        unsigned int extLocation;
} extent_adX;
#pragma pack()
struct super_blockX {
        unsigned long s_blocksize;
        unsigned char s_blocksize_bits;
        unsigned char s_dirt;
};
struct buffer_headX {
        struct buffer_head *b_next;
        unsigned long b_blocknr;
        unsigned short b_size;
        unsigned short b_list;
};
static void
udf_load_logicalvolintX(struct super_blockX *sb, extent_adX loc)
{
        struct buffer_headX *bh = ((void *)0);
        unsigned short ident;
        while ((bh = udf_read_taggedX(&ident)) && loc.extLength > 0)
        {
                loc.extLength -= sb->s_blocksize;
                loc.extLocation ++;
        }
}

http://gcc.gnu.org/cgi-bin/gnatsweb.pl?cmd=view&pr783&database=gcc




