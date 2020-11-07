import { API, graphqlOperation } from 'aws-amplify';
import { listSavings, listSpendings } from '../../graphql/queries';
import { createSaving, updateSaving } from '../../graphql/mutations';
import React, { useState, useEffect } from 'react';

export async function getSavingRepeat() {
  const today = new Date();

  const monthly = "Repeating monthly";
  const weekly = "Repeating weekly";
  const yearly = "Repeating yearly";


  try {
    let filter = {
      or: [
        { repeat: { eq: "Weekly" } },
        { repeat: { eq: "Monthly" } },
        { repeat: { eq: "Yearly" } },
        { repeat: { eq: "Repeating weekly" } },
        { repeat: { eq: "Repeating monthly" } },
        { repeat: { eq: "Repeating yearly" } },
      ]

    };

    const savingsData = await API.graphql(graphqlOperation(listSavings, { filter: filter }));
    const savingsList = savingsData.data.listSavings.items;


    for (var i = 0; i < savingsList.length; i++) {
      switch (savingsList[i].repeat) {
        case "Weekly":
          var dataDate = new Date();
          dataDate.setMonth(savingsList[i].month - 1);
          dataDate.setDate(savingsList[i].day);
          dataDate.setFullYear(savingsList[i].year);
          if (today.getTime() > dataDate.getTime()) {
            if (!savingsList[i].repeated) {
              var diff = Math.floor((today.getTime() - dataDate.getTime()) / (1000 * 60 * 60 * 24 * 7))
              console.log(diff)
              try {
                await API.graphql({
                  query: updateSaving,
                  variables: {
                    input: {
                      id: savingsList[i].id,
                      repeated: true
                    }
                  }
                })
                console.log('Saving repeated updated!');
              } catch (err) {
                console.log('Saving repeated could not update', err);
              }
              for (var j = 0; j < diff; j++) {
                dataDate.setDate(dataDate.getDate() + ((j + 1) * 7));
                try {
                  await API.graphql({
                    query: createSaving,
                    variables: {
                      input: {
                        month: ('0' + (dataDate.getMonth() + 1)).slice(-2),
                        day: ('0' + dataDate.getDate()).slice(-2),
                        year: dataDate.getFullYear(),
                        name: savingsList[i].name,
                        value: savingsList[i].value,
                        repeat: weekly,
                        note: savingsList[i].note,
                        repeated: true
                      }
                    }
                  })
                  console.log('CREATE');
                } catch (err) {
                  console.log({ err });
                }
                dataDate.setDate(dataDate.getDate() - ((j + 1) * 7));
              }
            }
            else {
              console.log('weekly already repeated')
            }
          }
          else {
            console.log('time traveling')
          }
          break;

        case "Monthly":
          var dataDate = new Date();
          dataDate.setMonth(savingsList[i].month - 1);
          dataDate.setDate(savingsList[i].day);
          dataDate.setFullYear(savingsList[i].year);
          if (today.getTime() > dataDate.getTime()) {
            if (!savingsList[i].repeated) {
              var diff = (today.getMonth() - dataDate.getMonth()) + (12 * (today.getFullYear() - dataDate.getFullYear()));
              var diffDays = today.getDate() - dataDate.getDate();
              if (diffDays < 0) {
                diff--;
              }
              try {
                await API.graphql({
                  query: updateSaving,
                  variables: {
                    input: {
                      id: savingsList[i].id,
                      repeated: true
                    }
                  }
                })
                console.log('Saving repeated updated!');
              } catch (err) {
                console.log('Saving repeated could not update', err);
              }
              for (var j = 0; j < diff; j++) {
                dataDate.setMonth(dataDate.getMonth() + (j + 1));
                try {
                  await API.graphql({
                    query: createSaving,
                    variables: {
                      input: {
                        month: ('0' + (dataDate.getMonth() + 1)).slice(-2),
                        day: ('0' + dataDate.getDate()).slice(-2),
                        year: dataDate.getFullYear(),
                        name: savingsList[i].name,
                        value: savingsList[i].value,
                        repeat: monthly,
                        note: savingsList[i].note,
                        repeated: true
                      }
                    }
                  })
                  console.log('CREATE');
                } catch (err) {
                  console.log({ err });
                }
                dataDate.setMonth(dataDate.getMonth() - (j + 1))
              }
            }
            else {
              console.log('monthly already repeated')
            }
          }
          else {
            console.log('time traveling')
          }
          break;

        case "Yearly":
          var dataDate = new Date();
          dataDate.setMonth(savingsList[i].month - 1);
          dataDate.setDate(savingsList[i].day);
          dataDate.setFullYear(savingsList[i].year);
          if (today.getTime() > dataDate.getTime()) {
            if (!savingsList[i].repeated) {
              var diff = (today.getFullYear() - dataDate.getFullYear());
              var diffMonths = today.getMonth() - dataDate.getMonth();
              var diffDays = today.getDate() - dataDate.getDate();
              if (diffMonths < 0) {
                diff--;
              }
              else if (diffMonths == 0) {
                if (diffDays < 0) {
                  diff--;
                }
              }
              console.log(diff)
              try {
                await API.graphql({
                  query: updateSaving,
                  variables: {
                    input: {
                      id: savingsList[i].id,
                      repeated: true
                    }
                  }
                })
                console.log('Saving repeated updated!');
              } catch (err) {
                console.log('Saving repeated could not update', err);
              }
              for (var j = 0; j < diff; j++) {
                dataDate.setFullYear(dataDate.getFullYear() + (j + 1));
                try {
                  await API.graphql({
                    query: createSaving,
                    variables: {
                      input: {
                        month: savingsList[i].month,
                        day: savingsList[i].day,
                        year: dataDate.getFullYear(),
                        name: savingsList[i].name,
                        value: savingsList[i].value,
                        repeat: yearly,
                        note: savingsList[i].note,
                        repeated: true
                      }
                    }
                  })
                  console.log('CREATE');
                } catch (err) {
                  console.log({ err });
                }
                dataDate.setFullYear(dataDate.getFullYear() - (j + 1))
              }
            }
          }
          break;

        case "Repeating weekly":
          var dataDate = new Date();
          dataDate.setMonth(savingsList[i].month - 1);
          dataDate.setDate(savingsList[i].day);
          dataDate.setFullYear(savingsList[i].year);
          if (today.getTime() > dataDate.getTime()) {
            var diff = Math.floor((today.getTime() - dataDate.getTime()) / (1000 * 60 * 60 * 24 * 7))
            if (diff > 0) {
              for (var j = 0; j < diff; j++) {
                dataDate.setDate(dataDate.getDate() + ((j + 1) * 7));
                try {
                  await API.graphql({
                    query: createSaving,
                    variables: {
                      input: {
                        month: ('0' + (dataDate.getMonth() + 1)).slice(-2),
                        day: ('0' + dataDate.getDate()).slice(-2),
                        year: dataDate.getFullYear(),
                        name: savingsList[i].name,
                        value: savingsList[i].value,
                        repeat: weekly,
                        note: savingsList[i].note,
                        repeated: true
                      }
                    }
                  })
                  console.log('CREATE');
                } catch (err) {
                  console.log({ err });
                }
                dataDate.setDate(dataDate.getDate() - ((j + 1) * 7));
              }
            }
          }
          break;

        case "Repeating monthly":
          var dataDate = new Date();
          dataDate.setMonth(savingsList[i].month - 1);
          dataDate.setDate(savingsList[i].day);
          dataDate.setFullYear(savingsList[i].year);
          if (today.getTime() > dataDate.getTime()) {
            var diff = (today.getMonth() - dataDate.getMonth()) + (12 * (today.getFullYear() - dataDate.getFullYear()));
            var diffDays = today.getDate() - dataDate.getDate();
            if (diffDays < 0) {
              diff--;
            }
            if (diff > 0) {
              for (var j = 0; j < diff; j++) {
                dataDate.setMonth(dataDate.getMonth() + (j + 1));
                try {
                  await API.graphql({
                    query: createSaving,
                    variables: {
                      input: {
                        month: ('0' + (dataDate.getMonth() + 1)).slice(-2),
                        day: ('0' + dataDate.getDate()).slice(-2),
                        year: dataDate.getFullYear(),
                        name: savingsList[i].name,
                        value: savingsList[i].value,
                        repeat: monthly,
                        note: savingsList[i].note,
                        repeated: true
                      }
                    }
                  })
                  console.log('CREATE');
                } catch (err) {
                  console.log({ err });
                }
                dataDate.setMonth(dataDate.getMonth() - (j + 1))
              }
            }
          }
          break;

        case "Repeating yearly":
          var dataDate = new Date();
          dataDate.setMonth(savingsList[i].month - 1);
          dataDate.setDate(savingsList[i].day);
          dataDate.setFullYear(savingsList[i].year);
          if (today.getTime() > dataDate.getTime()) {
            var diff = (today.getFullYear() - dataDate.getFullYear());
            var diffMonths = today.getMonth() - dataDate.getMonth();
            var diffDays = today.getDate() - dataDate.getDate();
            if (diffMonths < 0) {
              diff--;
            }
            else if (diffMonths == 0) {
              if (diffDays < 0) {
                diff--;
              }
            }
            if (diff > 0){
              for (var j = 0; j < diff; j++) {
                dataDate.setFullYear(dataDate.getFullYear() + (j + 1));
                try {
                  await API.graphql({
                    query: createSaving,
                    variables: {
                      input: {
                        month: savingsList[i].month,
                        day: savingsList[i].day,
                        year: dataDate.getFullYear(),
                        name: savingsList[i].name,
                        value: savingsList[i].value,
                        repeat: yearly,
                        note: savingsList[i].note,
                        repeated: true
                      }
                    }
                  })
                  console.log('CREATE');
                } catch (err) {
                  console.log({ err });
                }
                dataDate.setFullYear(dataDate.getFullYear() - (j + 1))
              }
            }
          }
          break;

        default:
          console.log('Not repeating');
      }
    }

  } catch (error) {
    return "Error getting saving repeat";
  }

}
