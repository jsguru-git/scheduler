
/*global _ sched */

sched.ns( 'tpl' );

sched.tpl.date = _.template( '<div class="col date-<%= date %>" data-date="<%= date %>">' +
                                 '<% if ( num == "1st" ) { %>' +
                                    '<span class="month">' +
                                        '<span class="label"><%= month %></span>' +
                                    '</span>' +
                                 '<% } %>' +
                                 '<span class="num"><%= num %></span>' +
                                 '<span class="word"><%= word %></span>' +
                             '</div>' );

sched.tpl.calendar = _.template( '<div class="users"></div>' +
                                 '<div class="scroller">' +
                                    '<div class="row row-date"></div>' +
                                    '<div class="entries"></div>' +
                                 '</div>' +
                                 '<div class="clearer"></div>' );

sched.tpl.users = _.template( '<% _.each( users, function(user) { %>' +
                                  '<div class="user user-<%= user.get(\'id\') %>" data-userid="<%= user.get(\'id\') %>" original-title="<%= user.get(\'firstname\') %> <%= user.get(\'lastname\') %>">' +
                                      '<a href="/users/<%= user.get(\'id\') %>">' +
                                          '<% if (user.get(\'user_calendar_image\') == 404) { %>' +
                                            '<div class="avatar avatar_initials" title="<%= user.get(\'firstname\') %> <%= user.get(\'lastname\') %>">' +
                                            '<%= user.get(\'firstname\')[0] %><%= user.get(\'lastname\')[0] %></div>' +
                                          '<% } else { %>' +
                                            '<div class="avatar avatar_initials" title="<%= user.get(\'firstname\') %> <%= user.get(\'lastname\') %>">' +
                                            '<img src="<%= user.get(\'user_calendar_image\') %>" /></div>' +
                                          '<% } %>' +
                                      '</a>' +
                                  '</div>' +
                              '<% }); %>' );

sched.tpl.data = _.template( '<div class="row ' +
                                    'row-data ' +
                                    'row-day-<%= dayOfWeek %> ' +
                                    'data-user-<%= user.get(\'id\') %>" ' +
                                   'data-userid="<%= user.get(\'id\') %>">' +
                                '</div>' );

