From: Keith Owens <kaos@ocs.com.au>
Date: Fri, 31 Jan 2003 04:56:09 +0000
Subject: Re: [Linux-ia64] Script for decoding PSR in oopses
Message-Id: <marc-linux-ia64-105590709805789@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805784@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805784@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 30 Jan 2003 20:41:19 -0800, 
"Wichmann, Mats D" <mats.d.wichmann@intel.com> wrote:
>david mosberger wrote
>> OK, now where is the Python version?? ;-))
>
>For once :-) the Perl isn't obtuse enough to
>make it necessary.  (grin)

Damn!  Now I have to return my "Perl Obfuscator" badge.  OTOH, this bit
from a Perl decoder for ia64 unwind data should reinstate my rating.
<ducks and runs>

my @decode_type;

sub set_decode_type()
{
    my ($i, $mask, $type, $start, $end);
    for ($i = 0; $i < 256; ++$i) {
	$decode_type[0][$i] = '?';
	$decode_type[1][$i] = '?';
    }
    foreach (
	#       prologue                    body
	[ 0, '00-- ----', 'R1' ], [ 1, '00-- ----', 'R1' ],
	[ 0, '0100 0---', 'R2' ], [ 1, '0100 0---', 'R2' ],
	[ 0, '0110 00--', 'R3' ], [ 1, '0110 00--', 'R3' ],
	[ 0, '100- ----', 'P1' ],
	[ 0, '1010 ----', 'P2' ],
	[ 0, '1011 0---', 'P3' ],
	[ 0, '1011 1000', 'P4' ],
	[ 0, '1011 1001', 'P5' ],
	[ 0, '110- ----', 'P6' ],
	[ 0, '1110 ----', 'P7' ],
	[ 0, '1111 0000', 'P8' ],
	[ 0, '1111 0001', 'P9' ],
	[ 0, '1111 1001', 'X1' ],
	[ 0, '1111 1010', 'X2' ],
	[ 0, '1111 1011', 'X3' ],
	[ 0, '1111 1100', 'X4' ],
	[ 0, '1111 1111', 'P10' ],
				   [ 1, '10-- ----', 'B1' ],
				   [ 1, '110- ----', 'B2' ],
				   [ 1, '1110 0000', 'B3' ],	# manual only lists this form for B3 ...
				   [ 1, '1110 1010', 'ea' ],	# ... but this one is used as well :(
				   [ 1, '1111 0000', 'B4' ],
				   [ 1, '1111 1000', 'B4' ],
				   [ 1, '1111 1001', 'X1' ],
				   [ 1, '1111 1010', 'X2' ],
				   [ 1, '1111 1011', 'X3' ],
				   [ 1, '1111 1100', 'X4' ],
    ) {
	$mask = '0b' . $_->[1];
	$mask =~ s/ //g;
	$start = $end = $mask;
	$start =~ s/-/0/g;
	$end =~ s/-/1/g;
	for ($i = oct($start); $i <= oct($end); ++$i) {
	    if ($decode_type[$_->[0]][$i] ne '?') {
		die("$0 decode_type[$_->[0]][$i] already set to $decode_type[$_->[0]][$i], ignoring $_->[2]\n");
	    }
	    $decode_type[$_->[0]][$i] = $_->[2];
	}
    }
}


