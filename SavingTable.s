import React, { useState, useEffect } from 'react';
import { 
  IconButton, InputAdornment, Table, TableBody, TableCell, 
  TableContainer, TableRow, TextField 
} from '@material-ui/core';
import { Search, Info } from '@material-ui/icons';

import { Auth, API, graphqlOperation } from "aws-amplify";
import { listSavings, savingsByOwner } from '../../graphql/queries';
import { deleteSaving } from '../../graphql/mutations';

import TableHeader from './TableHeader';
import { formatDate, stableSort, getComparator } from './TableFunctions';
import SnackbarNotification from '../Modals/SnackbarNotification';
import MoreSavingInformation from '../Modals/MoreSavingInformation';
import ConfirmDelete from '../Modals/ConfirmDelete';
import {getSavingRepeat} from '../Spending/GetRepeatData';
import './Table.css';

const columnTitles = [
  { id: "date", label: "Date", align: "center", minWidth: 50 },
  { id: "name", label: "Savings Name", align: "center", minWidth: 150 },
  { id: "value", label: "Value", align: "center", minWidth: 100, numeric: true },
  { id: "repeat", label: "Repeat", align: "center", minWidth: 100 },
  { id: "info", label: "More Information", align: "center", minWidth: 50 },
];

function SavingTable() {

  const [order, setOrder] = useState('desc');
  const [orderBy, setOrderBy] = useState('date');

  const [savings, setSaving] = useState([]);

  const [search, setSearch] = useState("");
  const [status, setStatusBase] = useState("");

  const [openAlert, setOpenAlert] = useState(true);

  const [showMore, setShowMore] = useState(false);
  const [itemID, setItemID] = useState("");
  const [data, setData] = useState({});
  const [showConfirmDelete, setConfirmDelete] = useState(false);
  const [savingsData, setSavingsData] = useState([]);

  useEffect(() => {
    fetchSaving();
    getSavingTotal();
  }, []);

  async function getSavingTotal() {
    const result = await getSavingRepeat();
    setSavingsData(result);
  }

  const handleRequestSort = (event, property) => {
    const isAsc = orderBy === property && order === "asc";
    setOrder(isAsc ? "desc" : "asc");
    setOrderBy(property);
  };

  const fetchSaving = async () => {
    if (search === "") {
      try {
        const savingData = await API.graphql(graphqlOperation(listSavings));
        const savingList = savingData.data.listSavings.items;
        console.log('saving data', savingList);
        setSaving(savingList);
      } catch (error) {
        console.log('Error on fetching saving', error)
      }
    }
    else {
      const owner = await Auth.currentAuthenticatedUser();
      const input = {
        owner: owner.username,
        name: {
          beginsWith: search,
        },
      };
      const savingData = await API.graphql(graphqlOperation(savingsByOwner, input));
      console.log('saving data', savingData);
      const savingList = savingData.data.savingsByOwner.items;
      console.log('saving list', savingList);
      if (savingList.length > 0) {
        setSaving(savingList);
        console.log('savings', savings);
      }
      else {
        setOpenAlert(true);
        setStatusBase("No match found.");
      }
    }
  };

  const handleClick = (event) => {
    event.preventDefault();
    fetchSaving();
  };

  const handleCloseAlert = (event, reason) => {
    if (reason === "clickaway") {
      return;
    }
    setOpenAlert(false);
  }

  async function handleDelete(event) {
    try {
      const id = {
        id: event
      }
      await API.graphql(graphqlOperation(deleteSaving, { input: id }));
      console.log('Deleted saving')
      window.location.reload();
    }
    catch (error) {
      console.log('Error on delete saving', error)
    }
  }

  function handleShowConfirmDelete() {
    setConfirmDelete(true);
  }

  return (
    <div>
      <TextField
        className="table-search"
        fullWidth
        InputLabelProps={{ shrink: true, }}
        InputProps={{
          endAdornment: (
            <InputAdornment>
              <IconButton className="table-icon" onClick={handleClick} type="submit">
                <Search />
              </IconButton>
            </InputAdornment>
          )
        }}
        onChange={e => setSearch(e.target.value)}
        placeholder="Search"
        value={search}
        variant="outlined"
      />
      <TableContainer className="table-container">
        <Table stickyHeader>
          <TableHeader
            headCells={columnTitles}
            order={order}
            orderBy={orderBy}
            onRequestSort={handleRequestSort}
          />
          <TableBody>
            {stableSort(savings, getComparator(order, orderBy))
              .map((saving) => {
                return (
                  <TableRow hover key={saving.id}>
                    <TableCell align="center">{formatDate(saving.month, saving.day, saving.year)}</TableCell>
                    <TableCell align="center">{saving.name}</TableCell>
                    <TableCell align="center">${saving.value}</TableCell>
                    <TableCell align="center">{saving.repeat}</TableCell>
                    <TableCell align="center">   
                      <IconButton 
                        className="table-icon" 
                        onClick={() => {
                          setItemID(saving.id);
                          //setData([saving.month, saving.day, saving.year, saving.name, saving.value, saving.repeat, saving.note]); 
                          setData({
                            month: saving.month,
                            day: saving.day,
                            year: saving.year,
                            name: saving.name,
                            value: saving.value,
                            repeat: saving.repeat,
                            note: saving.note
                          })
                          setShowMore(true);
                        }}> 
                        <Info /> 
                      </IconButton>
                    </TableCell>
                  </TableRow>
                )
              })
            }
          </TableBody>
        </Table>
      </TableContainer>
      {
        status ? 
          <SnackbarNotification 
            className="table-snackbar"
            message={status} 
            onClose={handleCloseAlert} 
            open={openAlert} 
            vertical="top"
          /> 
        : null
      }
      <MoreSavingInformation
        closeMore={() => setShowMore(!showMore)}
        confirmDelete={() => handleShowConfirmDelete()} 
        itemData={data}
        itemID={itemID}
        openMore={showMore}
      />
      <ConfirmDelete
        closeConfirmDelete={() => {
          setConfirmDelete(false);
          setShowMore(true);
        }}
        confirmed={() => {
          setConfirmDelete(false);
          handleDelete(itemID);
        }}
        openConfirmDelete={showConfirmDelete} 
      />
    </div>
  );
}

export default SavingTable;
