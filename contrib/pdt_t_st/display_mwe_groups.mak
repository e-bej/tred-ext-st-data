# vim: set syntax=perl:

{
    package PML_ST_Data;
    use strict;
    BEGIN { import TredMacro; }

    sub detect {
        return ( ( PML::SchemaName() || '' ) =~ /tdata/
              and PML::Schema->find_type_by_path('!t-root.type/mwes') ? 1 : 0 );
    }

    unshift @TredMacro::AUTO_CONTEXT_GUESSING, sub {
        my ($hook) = @_;
        my $resuming = ( $hook eq 'file_resumed_hook' );
        my $current = CurrentContext();
        if ( detect() ) {
            return __PACKAGE__;
        }
        return;
    };

# following MUST NOT be indented!
#binding-context PML_ST_Data

#include <contrib/support/fold_subtree.inc>

#bind fold_subtree_toggle to space menu Fold/unfold current subtree (toggle)
#bind fold_subtree_unfold_all to Ctrl+space menu Unfold all in the current subtree

    sub allow_switch_context_hook {
        return 'stop' unless detect();
    }

    sub switch_context_hook {
        PML_T::CreateStylesheets() && SetCurrentStylesheet('PML_T_Compact');
        Redraw() if GUI();
    }

    sub get_value_line_hook {
        PML_T::get_value_line_hook(@_);
    }

    sub after_redraw_hook {
        my %mwe_colours = (
            semlex      => 'maroon',
            person      => 'olive drab',
            institution => 'hot pink',
            location    => 'Turquoise1',
            object      => 'plum',
            address     => 'light slate blue',
            time        => 'lime green',
            biblio      => '#8aa3ff',
            foreign     => '#8a535c',
            other       => 'orange1',
        );
	
        # cyklus pres anotatory
	my @stipples = (qw(dense1 dense2 dense5 dense6));
	my $i = 0;
	foreach my $element ( ListV( $root->attr('mwes/annotator') ) ){ 
	    my $annotator = $element->{name}; 
	    my @stnodes = $element->value()->values(); # get a seq. of st-node values
	    foreach my $mwe_type ( keys %mwe_colours ) {
		my @these_mwes =
		  $mwe_type eq 'semlex'
		  ? grep { $_->{'lexicon-id'} =~ /^s#\d+$/ } @stnodes
		  : grep { $_->{'lexicon-id'} eq "s##$mwe_type" } @stnodes;
		foreach my $st (@these_mwes) {
	    print STDERR "$annotator: ", $stipples[$i], " - $mwe_type\n\n";
		    my @group =
		      map { PML_T::GetNodeByID($_) } ListV( $st->{'tnode.rfs'} );
		    TrEd::NodeGroups::draw_groups(
			$grp,
			[ [@group] ],
			{
			    colors   => [ $mwe_colours{$mwe_type} ],
			    stipples => [$stipples[$i]]
			  # group_line_width => 30, # default
			}
		    );
		}
	    }
	$i++; # change the stipple for the next annotator
	}
    }

}
1;
