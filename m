From: Keith Owens <kaos@ocs.com.au>
Date: Fri, 31 Jan 2003 02:10:58 +0000
Subject: Re: [Linux-ia64] Script for decoding PSR in oopses
Message-Id: <marc-linux-ia64-105590709805785@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805784@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805784@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 31 Jan 2003 12:46:00 +1100, 
Peter Chubb <peter@chubb.wattle.id.au> wrote:
>	I find trying to work out what the PSR is after an oops to be
>a bit of a pain, so here's an awk script to do it for you.
>
>Usage is
>      decode_psr hex_number
>if you save the script as decode_psr.

Below are Perl ia64_psr and ia64_isr.  Run as 
  echo hex_number | ia64_[pi]sr

== ia64_psr =
#!/usr/bin/perl -w
use strict;
use integer;

my @fields = (
	[ 0, 6, "User mask" ],
	[ 0, 1, "rv" ],
	[ 1, 1, "be" ],
	[ 2, 1, "up" ],
	[ 3, 1, "ac" ],
	[ 4, 1, "mfl" ],
	[ 5, 1, "mfh" ],
	[ 0, 24, "System mask" ],
	[ 6, 6, "rv" ],
	[ 13, 1, "ic" ],
	[ 14, 1, "i" ],
	[ 15, 1, "pk" ],
	[ 16, 1, "rv" ],
	[ 17, 1, "dt" ],
	[ 18, 1, "dfl" ],
	[ 19, 1, "dfh" ],
	[ 20, 1, "sp" ],
	[ 21, 1, "pp" ],
	[ 22, 1, "di" ],
	[ 23, 1, "si" ],
	[ 24, 1, "db" ],
	[ 25, 1, "lp" ],
	[ 26, 1, "tb" ],
	[ 27, 1, "rt" ],
	[ 28, 4, "rv" ],
	[ 32, 2, "cpl" ],
	[ 34, 1, "is" ],
	[ 35, 1, "mc" ],
	[ 36, 1, "it" ],
	[ 37, 1, "id" ],
	[ 38, 1, "da" ],
	[ 39, 1, "dd" ],
	[ 40, 1, "ss" ],
	[ 41, 2, "ri" ],
	[ 43, 1, "ed" ],
	[ 44, 1, "bn" ],
	[ 45, 1, "ia" ],
	[ 46, 18, "rv" ]
	);

while (defined($_ = <STDIN>)) {
	chomp();
	my $w0 = hex(substr($_, 0, -8));
	my $w1 = hex(substr($_, -8));
	printf("psr %s\n", $_);
	&ia64_psr($w1, 0, 32);
	&ia64_psr($w0, 32, 64);
}

sub ia64_psr()
{
	my ($w, $s, $e) = @_;
	my $v;
	foreach (@fields) {
		next if ($_->[0] >= $e);
		next if ($_->[0] < $s);
		# use integer implies signed shift, I want unsigned
		no integer;
		$v = ($w >> ($_->[0] - $s)) & (~0 >> (32 - $_->[1]));
		printf("%2d %2d %12s %x\n", $_->[0], $_->[1], $_->[2], $v);
	}
}

== ia64_isr =
#!/usr/bin/perl -w
use strict;
use integer;

my @fields = (
	[ 0, 16, "Code" ],
	[ 16, 8, "Vector" ],
	[ 24, 8, "rv" ],
	[ 32, 1, "x" ],
	[ 33, 1, "w" ],
	[ 34, 1, "r" ],
	[ 35, 1, "na" ],
	[ 36, 1, "sp" ],
	[ 37, 1, "rs" ],
	[ 39, 1, "ni" ],
	[ 40, 1, "so" ],
	[ 41, 2, "ei" ],
	[ 43, 1, "ed" ],
	[ 44, 20, "rv" ],
	);

while (defined($_ = <STDIN>)) {
	chomp();
	my $w0 = hex(substr($_, 0, -8));
	my $w1 = hex(substr($_, -8));
	printf("isr %s\n", $_);
	&ia64_isr($w1, 0, 32);
	&ia64_isr($w0, 32, 64);
}

sub ia64_isr()
{
	my ($w, $s, $e) = @_;
	my $v;
	foreach (@fields) {
		next if ($_->[0] >= $e);
		next if ($_->[0] < $s);
		# use integer implies signed shift, I want unsigned
		no integer;
		$v = ($w >> ($_->[0] - $s)) & (~0 >> (32 - $_->[1]));
		printf("%2d %2d %12s %x\n", $_->[0], $_->[1], $_->[2], $v);
	}
}


