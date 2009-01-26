#!/usr/bin/perl -w

use strict;

use Prophet::Test tests => 16;
use App::SD::Test;
no warnings 'once';

BEGIN {
    require File::Temp;
    $ENV{'PROPHET_REPO'} = $ENV{'SD_REPO'} = File::Temp::tempdir( CLEANUP => 0 ) . '/_svb';
    warn $ENV{'PROPHET_REPO'};
}

# tests for pseudo-commands that are only in the dispatcher

run_script( 'sd', [ 'init']);

# create from sd
my ($yatta_id, $yatta_uuid) = create_ticket_ok(    '--summary', 'YATTA', '--status', 'new' );

run_output_matches( 'sd', [ 'ticket',  
    'list', '--regex', '.' ],
    [  qr/(\d+) YATTA new/]
);

# test claim
run_output_matches( 'sd', [ 'ticket', 'claim', $yatta_id ],
    [ "Ticket $yatta_id ($yatta_uuid) updated." ]
);

run_output_matches( 'sd', [ 'ticket', 'basics', '--batch', '--id', $yatta_id ],
    [
        "id: $yatta_id ($yatta_uuid)",
        'summary: YATTA',
        'status: new',
        'milestone: alpha',
        'component: core',
        'owner: ' . $ENV{EMAIL},
        qr/^created: \d{4}-\d{2}-\d{2}.+$/,
        qr/^creator: /,
        'reporter: ' . $ENV{EMAIL},
        "original_replica: " . replica_uuid,
    ]
);

# revert back the change so we can check the alias for claim, take
run_output_matches( 'sd', [ 'ticket', 'update', $yatta_id, '--', 'owner', '' ],
    [ "Ticket $yatta_id ($yatta_uuid) updated." ]
);

run_output_matches( 'sd', [ 'ticket', 'basics', '--batch', '--id', $yatta_id ],
    [
        "id: $yatta_id ($yatta_uuid)",
        'summary: YATTA',
        'status: new',
        'milestone: alpha',
        'component: core',
        qr/^created: \d{4}-\d{2}-\d{2}.+$/,
        qr/^creator: /,
        'reporter: ' . $ENV{EMAIL},
        "original_replica: " . replica_uuid,
    ]
);

# test take
run_output_matches( 'sd', [ 'ticket', 'take', $yatta_id ],
    [ "Ticket $yatta_id ($yatta_uuid) updated." ]
);

run_output_matches( 'sd', [ 'ticket', 'basics', '--batch', '--id', $yatta_id ],
    [
        "id: $yatta_id ($yatta_uuid)",
        'summary: YATTA',
        'status: new',
        'milestone: alpha',
        'component: core',
        'owner: ' . $ENV{EMAIL},
        qr/^created: \d{4}-\d{2}-\d{2}.+$/,
        qr/^creator: /,
        'reporter: ' . $ENV{EMAIL},
        "original_replica: " . replica_uuid,
    ]
);

# test resolve
run_output_matches( 'sd', [ 'ticket', 'resolve', $yatta_id ],
    [ "Ticket $yatta_id ($yatta_uuid) updated." ]
);

run_output_matches( 'sd', [ 'ticket', 'basics', '--batch', '--id', $yatta_id ],
    [
        "id: $yatta_id ($yatta_uuid)",
        'summary: YATTA',
        'status: closed',
        'milestone: alpha',
        'component: core',
        'owner: ' . $ENV{EMAIL},
        qr/^created: \d{4}-\d{2}-\d{2}.+$/,
        qr/^creator: /,
        'reporter: ' . $ENV{EMAIL},
        "original_replica: " . replica_uuid,
    ]
);

# revert that change so we can test resolve's alias, close
run_output_matches( 'sd', [ 'ticket', 'update', $yatta_id, '--', 'status', 'new' ],
    [ "Ticket $yatta_id ($yatta_uuid) updated." ]
);

run_output_matches( 'sd', [ 'ticket', 'basics', '--batch', '--id', $yatta_id ],
    [
        "id: $yatta_id ($yatta_uuid)",
        'summary: YATTA',
        'status: new',
        'milestone: alpha',
        'component: core',
        'owner: ' . $ENV{EMAIL},
        qr/^created: \d{4}-\d{2}-\d{2}.+$/,
        qr/^creator: /,
        'reporter: ' . $ENV{EMAIL},
        "original_replica: " . replica_uuid,
    ]
);

# test close
run_output_matches( 'sd', [ 'ticket', 'close', $yatta_id ],
    [ "Ticket $yatta_id ($yatta_uuid) updated." ]
);

run_output_matches( 'sd', [ 'ticket', 'basics', '--batch', '--id', $yatta_id ],
    [
        "id: $yatta_id ($yatta_uuid)",
        'summary: YATTA',
        'status: closed',
        'milestone: alpha',
        'component: core',
        'owner: ' . $ENV{EMAIL},
        qr/^created: \d{4}-\d{2}-\d{2}.+$/,
        qr/^creator: /,
        'reporter: ' . $ENV{EMAIL},
        "original_replica: " . replica_uuid,
    ]
);

TODO: {
    local $TODO = "give interacts with the dispatcher in bad ways afaict";
    # test give
    run_output_matches( 'sd', [ 'ticket', 'give', $yatta_id, 'jesse@bestpractical.com' ],
        [ "Ticket $yatta_id ($yatta_uuid) updated." ]
    );

    run_output_matches( 'sd', [ 'ticket', 'basics', '--batch', '--id', $yatta_id ],
        [
            "id: $yatta_id ($yatta_uuid)",
            'summary: YATTA',
            'status: closed',
            'milestone: alpha',
            'component: core',
            'owner: jesse@bestpractical.com',
            qr/^created: \d{4}-\d{2}-\d{2}.+$/,
            qr/^creator: /,
            'reporter: ' . $ENV{EMAIL},
            "original_replica: " . replica_uuid,
        ]
    );
};